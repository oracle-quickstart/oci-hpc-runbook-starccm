# sudo yum install -y nmap
# nmap -sn $1 | grep "scan report" | sed -e "s/.*(\(.*\)).*/\1/" > iplist.txt
echo '' > run.sh
cat iplist.txt | while read line
do 
    echo "ssh -oStrictHostKeyChecking=no $line '" >> run.sh
    cat iplist.txt | while read line2
    do
        sed -i "$ s/$/ssh -oStrictHostKeyChecking=no $line2 'hostname';/" run.sh
    done
    sed -i "$ s/$/'/" run.sh
done
chmod 777 run.sh
./run.sh
echo end
