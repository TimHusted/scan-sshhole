#!/bin/bash

# Configuration files
SERVER_LIST="servers.txt"
USER_LIST="users.txt"
VERBOSE=0
PASSWORD=$(python3 -c "print('A' * 300)")
echo "Test Password:$PASSWORD"
# Verify required files exist
if [ ! -f "$SERVER_LIST" ]; then
    echo "Error: Server list file '$SERVER_LIST' not found."
    exit 1
fi

if [ ! -f "$USER_LIST" ]; then
    echo "Error: User list file '$USER_LIST' not found."
    exit 1
fi

# Outer Loop: Read through the servers file
while IFS= read -r SERVER_LINE || [ -n "$SERVER_LINE" ]; do
    # Skip empty lines and comments
    [[ -z "$SERVER_LINE" || "$SERVER_LINE" =~ ^# ]] && continue

    # Parse server and port. If ':' is missing, default to port 22.
    if [[ "$SERVER_LINE" == *":"* ]]; then
        SERVER="${SERVER_LINE%%:*}"
        PORT="${SERVER_LINE##*:}"
    else
        SERVER="$SERVER_LINE"
        PORT="22"
    fi

    echo "=================================================="
    echo "🌐 Target Server: $SERVER (Port: $PORT)"
    echo "=================================================="

    # Inner Loop: Read through the users file for the current server
    while IFS= read -r LOGINUSER || [ -n "$LOGINUSER" ]; do
        # Skip empty lines and comments in users file
        [[ -z "$LOGINUSER" || "$LOGINUSER" =~ ^# ]] && continue

        echo "Testing credentials for user [$LOGINUSER]..."

        # Call the expect script and pass the parameters
        ./ssh_test.exp "$LOGINUSER" "$SERVER" "$PORT" "$PASSWORD"
        
        # Capture the exit code of the expect script
        STATUS=$?

        if [ $STATUS -eq 0 ]; then
            echo "  ✅ VULNERABLE: [$LOGINUSER] to [$SERVER] - REMEDIATE."
        elif [ $STATUS -eq 1 ]; then
             if [ $VERBOSE -eq 1 ]; then
                 echo "  ❌ FAILURE: Login rejected for [$LOGINUSER]."
             fi
                     elif [ $STATUS -eq 2 ]; then
             if [ $VERBOSE -eq 1 ]; then
                 echo "  ⚠️ TIMEOUT: Could not reach server (Network/Firewall)."
             fi
            # Optional optimization: Break inner loop if the server itself is down
            # break
        else
             if [ $VERBOSE -eq 1 ]; then
                 echo "  ⚠️ ERROR: Unexpected failure (Exit code: $STATUS)."
             fi
        fi
        echo "--------------------------------------------------"

    done < "$USER_LIST"

done < "$SERVER_LIST"