 if (Test-Path "\\network_path\Plat_XY_Import\xy_exports.xlsx") {

     py "\\network_path\ttrice\Python Scripts\Projects\PlatXYImport\py_ImportXYCoordinates.py" "\\network_path\Plat_XY_Import\xy_exports.xlsx"

     #pause

 }
 else {

    exit

 }