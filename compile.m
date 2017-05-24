%% compile necessary functions    
    cd ./SLIC_Feature
    mex -O SLIC_mex.cpp SLIC.cpp
    cd ..