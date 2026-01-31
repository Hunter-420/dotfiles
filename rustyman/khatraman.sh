#!/usr/bin/env bash
set -e

# ================= CONFIGURATION =================
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"

# Resolve Script Directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$SCRIPT_DIR/config.env"

# Load local defaults if file exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    # echo "Loaded config from $CONFIG_FILE" # Debug
else
    echo -e "${YELLOW}[WARN] Config file not found at $CONFIG_FILE${NC}"
fi

# Default values (can be overridden by env vars or CLI args)
DEFAULT_HOST="${HOST:-http://localhost:9393}"

# If DEFAULT_EXCHANGE is not set in config, fallback to 'weex-common'
DEFAULT_EXCHANGE="${DEFAULT_EXCHANGE:-weex-common}" 
# If DEFAULT_PAIR is not set in config, fallback to 'PBTC/USDT'
DEFAULT_PAIR="${DEFAULT_PAIR:-PBTC/USDT}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ================= HELPER FUNCTIONS =================

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

check_deps() {
    local missing=0
    for cmd in jq curl; do
        if ! command -v $cmd &>/dev/null; then
            log_error "Missing dependency: $cmd"
            missing=1
        fi
    done
    if [ $missing -eq 1 ]; then
        exit 1
    fi
}

# Resolve binaries
JQ_BIN=$(command -v jq)
CURL_BIN=$(command -v curl)
DATE_BIN=$(command -v date)
TAIL_BIN=$(command -v tail)
HEAD_BIN=$(command -v head)
MKTEMP_BIN=$(command -v mktemp)
RM_BIN=$(command -v rm)
CAT_BIN=$(command -v cat)
REDIS_CLI=$(command -v redis-cli)
AWK_BIN=$(command -v awk)

[ -z "$DATE_BIN" ] && log_error "date command not found"






# Fetch Exchange Info (Redis or Local)
get_exchange_info() {
    local exchange=$1
    local source=${DATA_SOURCE:-local}

    if [[ "$source" == "redis" ]]; then
        if [ -z "$REDIS_CLI" ]; then
             log_error "redis-cli not found, falling back to local config."
             source="local"
        else
            # Fetch all bots from Redis (hgetall returns key, value lines. We want values, which are on even lines)
            # Use awk to filter even lines (the JSON values)
            # Use jq to find the matching bot config
            # Logic: Match pair AND (exchange name with or without -common suffix)
            local bot_config
            bot_config=$($REDIS_CLI -h 127.0.0.1 -p 6379 hgetall bots | \
                $AWK_BIN 'NR % 2 == 0' | \
                $JQ_BIN -c --arg ex "$exchange" --arg pair "$DEFAULT_PAIR" '
                    select(
                        (.config.pair == $pair) and 
                        ((.config.exchange | sub("-common$";"")) == ($ex | sub("-common$";"")))
                    ) | 
                    {
                        exchangeName: .config.exchange,
                        uid: .config.uid,
                        apiKey: .config.api_key,
                        apiSecret: .config.api_secret,
                        sandbox: false, 
                        enableRateLimit: false
                    }
                ' | $HEAD_BIN -n1)
            
            if [ -n "$bot_config" ]; then
                echo "$bot_config"
                return
            else
                log_error "No config found for exchange '$exchange' and pair '$DEFAULT_PAIR' in Redis. Using local fallback."
            fi

        fi
    fi


    # Fallback/Local Construction
    $JQ_BIN -nc \
        --arg k "$exchange" \
        --arg uid "${EXCHANGE_UID:-quo1234}" \
        --arg key "${API_KEY:-msg_key}" \
        --arg secret "${API_SECRET:-msg_secret}" \
        '{exchangeName:$k, uid:$uid, apiKey:$key, apiSecret:$secret, sandbox:false, enableRateLimit:false}'


}

print_usage() {
    echo -e "${YELLOW}Usage:${NC} $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  balance          Fetch Balance"
    echo "  ticker           Fetch Ticker"
    echo "  trades           Fetch My Trades"
    echo "  orderbook        Fetch Order Book"
    echo "  openorders       Fetch Open Orders"
    echo "  getorder         Get Specific Order Status"
    echo "  create           Create New Order"
    echo "  createmulti      Place Multiple Orders"
    echo "  cancel           Cancel Order"
    echo "  cancelall        Cancel All Orders"
    echo "  deposit          Get Deposit Address"
    echo ""
    echo "Options:"
    echo "  --exchange <name>   Exchange name (default: $DEFAULT_EXCHANGE)"
    echo "  --pair <symbol>     Trading pair (default: $DEFAULT_PAIR)"
    echo "  --host <url>        Connector URL (default: $DEFAULT_HOST)"
    echo "  key=value           Override any JSON body parameter (e.g. price=0.5 side=sell)"
    echo ""
}

# ================= MAIN LOGIC =================

check_deps

# Variables
CMD=""
ARGS=()
OVERRIDES=()
DEBUG_MODE=0

# Parse Args
while [[ $# -gt 0 ]]; do
    case $1 in
        --exchange)
            DEFAULT_EXCHANGE="$2"
            shift 2
            ;;
        --pair)
            DEFAULT_PAIR="$2"
            shift 2
            ;;
        --host)
            DEFAULT_HOST="$2"
            shift 2
            ;;
        --debug)
            DEBUG_MODE=1
            shift
            ;;
        --help)
            print_usage
            exit 0
            ;;
        *=*)

            OVERRIDES+=("$1")
            shift
            ;;
        *)
            if [ -z "$CMD" ]; then
                CMD="$1"
            else
                ARGS+=("$1")
            fi
            shift
            ;;
    esac
done

# Interactive Menu if no command
INTERACTIVE=0
if [ -z "$CMD" ]; then
    INTERACTIVE=1
    echo -e "${CYAN}No command specified. Select an action:${NC}"
    select opt in "balance" "ticker" "trades" "orderbook" "openorders" "getorder" "create" "createmulti" "cancel" "cancelall" "deposit" "Exit"; do
        case $opt in
            "Exit") exit 0 ;;
            *) CMD=$opt; break ;;
        esac
    done
fi

# Endpoint Config
METHOD="POST"
PATH=""
BODY="{}"

case "$CMD" in
    balance)
        METHOD="GET"
        PATH="/balance"
        ;;
    ticker)
        PATH="/ticker"
        BODY='{"symbol": "{{pair}}"}'
        ;;
    trades)
        PATH="/my-trades"
        BODY='{"symbol": "{{pair}}", "size": 1000}'
        ;;
    orderbook)
        PATH="/order-book"
        BODY='{"symbol": "{{pair}}"}'
        ;;
    openorders)
        PATH="/open-orders"
        BODY='{"symbol": "{{pair}}"}'
        ;;
    getorder)
        PATH="/get-order"
        # ID needs to be supplied or we use a dummy default
        BODY='{"symbol": "{{pair}}", "id": "ORDER_ID_HERE"}'
        ;;
    create)
        PATH="/create-order"
        FILE_PATH="$SCRIPT_DIR/orders/create-order.json"
        
        if [ "$INTERACTIVE" -eq 1 ]; then
            echo -e "${CYAN}Enter Order Details:${NC}"
            read -p "Type (limit/market): " _type
            read -p "Side (buy/sell): " _side
            read -p "Amount: " _amount
            read -p "Price: " _price
            
            # Construct JSON using jq
            BODY=$($JQ_BIN -n \
                --arg s "$DEFAULT_PAIR" \
                --arg t "$_type" \
                --arg sd "$_side" \
                --arg a "$_amount" \
                --arg p "$_price" \
                '{symbol: $s, type: $t, side: $sd, amount: ($a|tonumber), price: ($p|tonumber)}')
        elif [ -f "$FILE_PATH" ]; then
            log_info "Loading body from $FILE_PATH"
            # Read file, override symbol with config pair
            BODY=$($JQ_BIN -c --arg s "$DEFAULT_PAIR" '.symbol = $s' "$FILE_PATH")
        else
            BODY='{"symbol": "{{pair}}", "type": "limit", "side": "buy", "amount": 50, "price": 0.17}'
        fi
        ;;
    createmulti)
        PATH="/place-multi-orders"
        BODY='{"pair": "{{pair}}", "side": "buy", "lowerPrice": 59, "upperPrice": 78, "numberOfOrders": 20, "quantityPerOrder": 1270, "priceDecimals": 6, "quantityDecimals": 6}'
        ;;
    cancel)
        PATH="/cancel-order"
        FILE_PATH="$SCRIPT_DIR/orders/cancel-order.json"

        if [ "$INTERACTIVE" -eq 1 ]; then
             echo -e "${CYAN}Enter Order Details:${NC}"
             read -p "Order ID: " _id
             if [ -z "$_id" ]; then
                 log_error "Order ID is required!"
                 exit 1
             fi
             BODY=$($JQ_BIN -n --arg s "$DEFAULT_PAIR" --arg id "$_id" '{symbol: $s, id: $id}')
        elif [ -f "$FILE_PATH" ]; then
            log_info "Loading body from $FILE_PATH"
            BODY=$($JQ_BIN -c --arg s "$DEFAULT_PAIR" '.symbol = $s' "$FILE_PATH")
        else
            BODY='{"symbol": "{{pair}}", "id": "ORDER_ID_HERE"}'
        fi
        ;;
    cancelall)
        PATH="/cancel-all-orders"
        BODY='{"symbol": "{{pair}}"}'
        ;;
    deposit)
        METHOD="GET"
        PATH="/deposit"
        ;;
    *)
        log_error "Unknown command: $CMD"
        print_usage
        exit 1
        ;;
esac

# Prepare URL
URL="${DEFAULT_HOST}${PATH}"

# Prepare Headers
EXCHANGE_DATA=$(get_exchange_info "$DEFAULT_EXCHANGE")
HEADER_EXCHANGE="x-exchange-information: $EXCHANGE_DATA"

# Prepare Body (Replace Variables)
if [[ "$METHOD" == "POST" ]]; then
    # 1. Replace {{pair}}
    BODY=${BODY//\{\{pair\}\}/$DEFAULT_PAIR}
    
    # 2. Apply Overrides
    for override in "${OVERRIDES[@]}"; do
        KEY="${override%%=*}"
        VAL="${override#*=}"
        
        # Determine if value is number or string for JSON
        if [[ "$VAL" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
            # Valid number
            JQ_ARG="--argjson v $VAL"
        else
            # String
            JQ_ARG="--arg v $VAL"
        fi
        
        BODY=$(echo "$BODY" | $JQ_BIN "$JQ_ARG" ".${KEY} = \$v")
    done
fi

log_info "Executing ${YELLOW}$CMD${NC} on $DEFAULT_EXCHANGE ($DEFAULT_PAIR)"
[ "$METHOD" == "POST" ] && echo -e "Payload: $BODY"

# Execute
START=$($DATE_BIN +%s%3N)

# Create temp file for body
RESP_BODY_FILE=$($MKTEMP_BIN)

CURL_CMD="$CURL_BIN -sS -o '$RESP_BODY_FILE' -w '%{http_code}'"


if [[ "$METHOD" == "POST" ]]; then
    CURL_CMD="$CURL_CMD -X POST '$URL' -H 'Content-Type: application/json' -H '$HEADER_EXCHANGE' -d '$BODY'"
    # Execute
    if [ $DEBUG_MODE -eq 1 ]; then
        echo -e "${YELLOW}[DEBUG] Command:${NC} $CURL_CMD"
    fi
     HTTP_CODE=$($CURL_BIN -sS -o "$RESP_BODY_FILE" -w "%{http_code}" -X POST "$URL" \
        -H "Content-Type: application/json" \
        -H "$HEADER_EXCHANGE" \
        -d "$BODY")
else
    CURL_CMD="$CURL_CMD -X GET '$URL' -H '$HEADER_EXCHANGE'"
    # Execute
    if [ $DEBUG_MODE -eq 1 ]; then
        echo -e "${YELLOW}[DEBUG] Command:${NC} $CURL_CMD"
    fi
    HTTP_CODE=$($CURL_BIN -sS -o "$RESP_BODY_FILE" -w "%{http_code}" -X GET "$URL" \
        -H "$HEADER_EXCHANGE")
fi


CURL_EXIT_CODE=$?
END=$($DATE_BIN +%s%3N)
DIFF=$((END - START))

if [ $CURL_EXIT_CODE -ne 0 ]; then
    log_error "Curl command failed with exit code $CURL_EXIT_CODE"
    $RM_BIN -f "$RESP_BODY_FILE"
    exit $CURL_EXIT_CODE
fi

# Output
echo ""
if [[ "$HTTP_CODE" -ge 400 ]]; then
    echo -e "${RED}[ERROR] Status Code: $HTTP_CODE${NC}"
else
    echo -e "${GREEN}[SUCCESS] Status Code: $HTTP_CODE${NC} (${DIFF}ms)"
fi

echo -e "Response Body:"

if [ -s "$RESP_BODY_FILE" ]; then
    # Try to pretty print response if valid JSON, else raw
    if $JQ_BIN . "$RESP_BODY_FILE" >/dev/null 2>&1; then
        $JQ_BIN . "$RESP_BODY_FILE"
    else
        $CAT_BIN "$RESP_BODY_FILE"
    fi
else
    echo "(Empty Response Body)"
fi

# Cleanup
$RM_BIN -f "$RESP_BODY_FILE"

