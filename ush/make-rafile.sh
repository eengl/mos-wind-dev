#!/bin/sh

if [ $# -ne 3 ]; then
   echo "Usage: $(basename $0) MAXENT NBYTES CFILX"
   exit 1
else
   MAXENT=$1
   NBYTES=$2
   CFILX=$3
fi

U350DIR=/mdlstat/save/usr/$USER/u350/sorc

# ============================================================================== 
# Generate control file for u350.  This is safe becuase the control file is
# very simple.
# ============================================================================== 
printf "%8d%8d %-60s\n%8d\n" $MAXENT $NBYTES $CFILX 9999 > U350.CN

# ============================================================================== 
# Run!
# ============================================================================== 
$U350DIR/u350.x < U350.CN

# ============================================================================== 
# Cleanup!
# ============================================================================== 
rm -f U350.CN
