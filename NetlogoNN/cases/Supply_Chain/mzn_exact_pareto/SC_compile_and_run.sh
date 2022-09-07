
# python3 ../NN_SupplyChainTraining.py
emzn2fzn.py supply_chain.mzn supply_chain.dzn 
echo "done compiling"
fzn2optimathsat.py supply_chain.fzn -opt.priority=box -opt.box.engine=full 

