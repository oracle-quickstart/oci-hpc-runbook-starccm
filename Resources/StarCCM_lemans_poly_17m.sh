#!/bin/bash

#GET BASIC SYSTEM INFO
uid=`uuidgen | cut -c-8`
OS_VERS=`cat /etc/*-release | grep "PRETTY_NAME" | cut -d= -f2`
OS_VERS=`echo "$OS_VERS" | sed -e 's/^"//' -e 's/"$//'`
KERNEL_VERS=`uname -r`
HPC_TOOLS_VERS="N/A"
dt=$( date '+%FT%H:%M:%S'.123Z )

ulimit -s unlimited
ulimit -l unlimited
ulimit -n 8192
ulimit -a

#COMMAND LINE VARIABLES:
StarCCM_Version=
INSTALLPATH=/nfs/scratch/starccm/install/
MODEL=lemans_poly_100m
MODELNAME=/nfs/scratch/starccm/work/lemans/data/case/lemans_poly_17m.amg.sim
POD=
benchITS=
CORES=
PPN=
MACHINEFILE=/nfs/scratch/starccm/work
MPI_NAME=intel
RDMA_INTERFACE=enp94s0f0
TCP_INTERFACE=enp65s0f0 


#Set MPI Parameters
if [ "$INSTANCE" == "BM.HPC2.36" ]
then
    if [ "$MPI_NAME" == "openmpi" ]; then
       #Set MPI flags
       MPI_FLAGS="-mca btl self -x UCX_TLS=rc,self,sm -x HCOLL_ENABLE_MCAST_ALL=0 -mca coll_hcoll_enable 0 -x UCX_IB_TRAFFIC_CLASS=105 -x UCX_IB_GID_INDEX=3"
       FABRIC=""

    elif [ "$MPI_NAME" == "intel" ]; then
       #Set MPI Flags
       MPI_FLAGS="-iface "$RDMA_INTERFACE" -genv I_MPI_FABRICS=shm:dapl -genv DAT_OVERRIDE=/etc/dat.conf -genv I_MPI_DAT_LIBRARY=/usr/lib64/libdat2.so -genv I_MPI_DAPL_PROVIDER=ofa-v2-cma-roe-"$RDMA_INTERFACE" -genv I_MPI_FALLBACK=0 -genv I_MPI_PIN_PROCESSOR_LIST=0-35 -genv I_MPI_PROCESSOR_EXCLUDE_LIST=36-71"
       FABRIC=""

    else
       MPI_FLAGS=""
       FABRIC=""
    fi
else
    if [ "$MPI_NAME" == "openmpi" ]; then
        #Set MPI flags
        MPI_FLAGS="-mca btl tcp,self --mca btl_tcp_if_include $TCP_INTERFACE --mca oob_tcp_if_include $TCP_INTERFACE --mca oob_tcp_disable_family IPv6 -x HCOLL_ENABLE_MCAST_ALL=0 -mca coll_hcoll_enable 0"
        FABRIC="TCP"

    elif [ "$MPI_NAME" == "intel" ]; then
        #Set MPI flags
        MPI_FLAGS="-iface $TCP_INTERFACE -genv I_MPI_FABRICS=tcp -genv I_MPI_FALLBACK=0"
        FABRIC="TCP"
    else
        MPI_FLAGS=""
        FABRIC="TCP"
    fi
fi



BASE_EXECUTION_TIME=0
BASE_CORES=0
INIT_TEST="INIT"

#LOG EVENT
echo `date` | tee -a ${MPI_NAME}.${CORES}.${unique}.log
#RUN SIMULATION
if [ $MPI_NAME == intel ]; then
  $INSTALLPATH/star/bin/starccm+ -v -power -licpath 1999@flex.cd-adapco.com -podkey $POD -np $CORES -benchmark "-preclear -preits 40 -nits 10 -nps $benchITS" -machinefile $MACHINEFILE -rsh ssh -mpi $MPI_NAME -cpubind bandwidth,v -mppflags "$MPI_FLAGS" -load $MODELNAME | tee -a ${MPI_NAME}.${CORES}.${unique}.log
elif [ $MPI_NAME == openmpi ]; then
  $INSTALLPATH/star/bin/starccm+ -v -power -licpath 1999@flex.cd-adapco.com -podkey $POD -np $CORES -benchmark "-preclear -preits 40 -nits 20 -nps $benchITS" -machinefile $MACHINEFILE -rsh ssh -mpi $MPI_NAME -cpubind bandwidth,v -mppflags "$MPI_FLAGS" -load $MODELNAME | tee -a ${MPI_NAME}.${CORES}.${unique}.log
elif [ $MPI_NAME == platform ]; then
  $INSTALLPATH/star/bin/starccm+ -v -power -licpath 1999@flex.cd-adapco.com -podkey $POD -np $CORES -nosuite -machinefile $MACHINEFILE -rsh ssh -mpi $MPI_NAME -mppflags "$MPI_FLAGS" -benchmark "-preclear -preits 40 -nits 20 -nps $benchITS" $MODELNAME | tee -a ${MPI_NAME}.{$CORES}.${unique}.log
fi

#LOG EVENT
echo `date` | tee -a ${MPI_NAME}.${CORES}.${UNIQUEID}.log


# Find the xml file
XML=`cat ${MPI_NAME}.${CORES}.${UNIQUEID}.log | grep 'Benchmark::Output file name :' | cut -d ' ' -f 5`

# Get the data that remains constant
MPI_VERSION=`xmllint --xpath '//MpiType/text()' $XML`
StarCCM_Version=`xmllint --xpath '//Version/text()' $XML`
MODELNAME=`xmllint --xpath '//Name/text()' $XML`
RUNDATE=`xmllint --xpath '//RunDate/text()' $XML`
CELLS=`xmllint --xpath '//NumberOfCells/text()' $XML`
# HOSTNAME=`xmllint --xpath '//HostName/text()' $XML`
NODES=`xmllint --xpath '//NumberOfHosts/text()' $XML`
MPI_VERSION_NUMBER=$(echo $MPI_VERSION | cut -d ' ' -f 2)

# Get data that has multiple values
SPEEDUP=`sed -n 's:.*<SpeedUp>\(.*\)</SpeedUp>.*:\1:p' $XML`
AVERAGE_ELAPSED_TIME=`sed -n 's:.*<AverageElapsedTime Units=\"seconds\">\(.*\)</AverageElapsedTime>.*:\1:p' $XML`
WORKERS=`sed -n 's:.*<NumberOfWorkers>\(.*\)</NumberOfWorkers>.*:\1:p' $XML`

# Get number of benchmark runs and iterate through the results
BENCH_RUNS=`xmllint --xpath '//NumberOfSamples/text()' $XML`
NUM_CORES=128

for RUNS in 1 $BENCH_RUNS; do

   CORES_TEMP=$(echo $WORKERS | cut -d ' ' -f $RUNS)
   SPEEDUP_TEMP=$(echo $SPEEDUP | cut -d ' ' -f $RUNS)
   TIME=$(echo $AVERAGE_ELAPSED_TIME | cut -d ' ' -f $RUNS)

   CELLSCORE=`echo "scale=2;$CELLS/$CORES_TEMP" | bc`
   SCALING=`echo "scale=2;$SPEEDUP_TEMP/$CORES_TEMP" | bc`
   NODES_TEMP=`echo "scale=0;$CORES_TEMP/$NUM_CORES" | bc`


done
