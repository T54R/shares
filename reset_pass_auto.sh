#!/bin/bash

set -e

echo "==== WebLogic Admin Password Reset Script ===="

# ----------- 1. Detect DOMAIN_HOME -----------

# Try to detect DOMAIN_HOME by looking for typical domain dir:
POSSIBLE_DOMAINS=(
  "$HOME/app/oracle/product/fmw12c/user_projects/domains/base_domain"
  "$HOME/app/oracle/product/fmw11g/user_projects/domains/base_domain"
  "/home/oracle/app/oracle/product/fmw12c/user_projects/domains/base_domain"
  "/home/oracle/app/oracle/product/fmw11g/user_projects/domains/base_domain"
)

DOMAIN_HOME=""
for d in "${POSSIBLE_DOMAINS[@]}"; do
  if [ -d "$d" ]; then
    DOMAIN_HOME="$d"
    break
  fi
done

if [ -z "$DOMAIN_HOME" ]; then
  echo "ERROR: Could not detect DOMAIN_HOME automatically."
  echo "Please set DOMAIN_HOME manually in the script."
  exit 1
fi

echo "Detected DOMAIN_HOME: $DOMAIN_HOME"

# ----------- 2. Detect ORACLE_HOME -----------

# Check env ORACLE_HOME first
if [ -n "$ORACLE_HOME" ] && [ -d "$ORACLE_HOME" ]; then
  echo "Using ORACLE_HOME from env: $ORACLE_HOME"
else
  # Try to guess ORACLE_HOME based on DOMAIN_HOME path (typical structure)
  ORACLE_HOME=$(dirname $(dirname $(dirname "$DOMAIN_HOME")))
  if [ -d "$ORACLE_HOME" ]; then
    echo "Detected ORACLE_HOME: $ORACLE_HOME"
  else
    echo "ERROR: Could not detect ORACLE_HOME. Please set it manually."
    exit 1
  fi
fi

# ----------- 3. Detect WLST executable -----------

WLST_PATHS=(
  "$ORACLE_HOME/oracle_common/common/bin/wlst.sh"
  "$ORACLE_HOME/oracle_common/common/bin/wlst"
  "$ORACLE_HOME/wlserver/common/bin/wlst.sh"
  "$ORACLE_HOME/wlserver/common/bin/wlst"
)

WLST=""
for p in "${WLST_PATHS[@]}"; do
  if [ -x "$p" ]; then
    WLST="$p"
    break
  fi
done

if [ -z "$WLST" ]; then
  echo "ERROR: Could not find WLST executable. Please check ORACLE_HOME and WLST installation."
  exit 1
fi

echo "Found WLST executable at: $WLST"

# ----------- 4. Locate AdminServer PID -----------

PID_FILE="${DOMAIN_HOME}/servers/AdminServer/data/nodemanager/AdminServer.pid"
if [ -f "$PID_FILE" ]; then
  ADMIN_PID=$(cat "$PID_FILE")
  if ps -p "$ADMIN_PID" > /dev/null 2>&1; then
    echo "AdminServer is running with PID: $ADMIN_PID"
  else
    echo "AdminServer PID file found but no running process with PID $ADMIN_PID."
    ADMIN_PID=""
  fi
else
  echo "AdminServer PID file not found, assuming server is not running."
  ADMIN_PID=""
fi

# ----------- 5. Confirm before proceeding -----------

echo
echo "===== Summary ====="
echo "DOMAIN_HOME: $DOMAIN_HOME"
echo "ORACLE_HOME: $ORACLE_HOME"
echo "WLST: $WLST"
if [ -n "$ADMIN_PID" ]; then
  echo "AdminServer PID: $ADMIN_PID"
else
  echo "AdminServer: NOT running"
fi
echo "==================="

read -p "Proceed with resetting admin password and restarting AdminServer? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Aborted by user."
  exit 0
fi

# ----------- 6. Stop AdminServer gracefully if running -----------

if [ -n "$ADMIN_PID" ]; then
  echo "Stopping AdminServer (PID=$ADMIN_PID)..."
  kill -TERM "$ADMIN_PID"

  # Wait for it to stop
  while ps -p "$ADMIN_PID" > /dev/null 2>&1; do
    echo "Waiting for AdminServer to stop..."
    sleep 5
  done
  echo "AdminServer stopped."
else
  echo "AdminServer is not running, skipping stop."
fi

# ----------- 7. Prepare WLST script to reset password -----------

cat > /tmp/resetWLSPassword.py <<EOF
domain = '$DOMAIN_HOME'
username = 'weblogic'
new_pass = 'N010v3'

print('Reading domain...')
readDomain(domain)

print('Resetting password for %s...' % username)
cd('/Security/BaseDomain/User/' + username)
cmo.setPassword(new_pass)

print('Updating and closing...')
updateDomain()
closeDomain()
exit()
EOF

# ----------- 8. Run WLST password reset -----------

echo "Running WLST to reset password..."
$WLST /tmp/resetWLSPassword.py
WLST_EXIT=$?

if [ $WLST_EXIT -ne 0 ]; then
  echo "ERROR: WLST script failed with exit code $WLST_EXIT"
  exit 1
fi

echo "Password reset successful."

# ----------- 9. Restart AdminServer -----------

echo "Starting AdminServer..."
"$DOMAIN_HOME/bin/startWebLogic.sh" &

echo "Waiting 2 minutes for AdminServer to start..."
sleep 120

echo "Script completed successfully."
