import sys
sys.path.append(r"\\network_path\ttrice\Python Scripts\Projects\PlatXYImport\venv\Lib\site-packages")
# https://stackoverflow.com/questions/15514593/importerror-no-module-named-when-trying-to-run-python-script
import pandas as pd
import logging
from pathlib import Path
from datetime import date
import sys # for passing in command line argument
#pd.set_option('display.max_columns',10)

log_file = r'\\network_path\Plat_XY_Import\xy_log.log'
logging.basicConfig(filename=log_file, encoding='utf-8', level=logging.DEBUG, format='%(asctime)s %(message)s')

def send_email(receiver):
    # https://leimao.github.io/blog/Python-Send-Gmail/
    import smtplib, ssl
    from email.message import EmailMessage

    port = 465  # For SSL # Change to 587 
    smtp_server = "smtp.gmail.com"
    sender_email = "example@gmail.com"  # Enter your address
    password = "xyz"

    msg = EmailMessage()
    msg.set_content(log_file)
    msg['Subject'] = "***XY Coordinate Import Failure***"
    msg['From'] = sender_email
    msg['To'] = receiver

    context = ssl.create_default_context()
    with smtplib.SMTP_SSL(smtp_server, port, context=context) as server:
        server.login(sender_email, password)
        server.send_message(msg, from_addr=sender_email, to_addrs=receiver)


logging.info('Attempting to Read File...')
try:
    excel_file = Path(sys.argv[1])  # Testing File >> 'xy_exports.xlsx'
    abs_path = excel_file.resolve(strict=True)
except FileNotFoundError:
    logging.info('The File Does Not Exist or the Path was Entered Incorrectly')
    send_email("tyler@gmail.com")
    exit()
else:
    logging.info('Beginning Import Process...')
    try:
        original_df = pd.read_excel(io = excel_file,
                           sheet_name=0,
                           header=0,
                           #names = [],
                           index_col=None,
                           usecols=("AIN", "x", "y") # "I,M,N" > AIN, X-Coord, Y-Coord Fields
                           #skiprows=1,
                           #skipfooter=1
                           )
        #print(original_df)

        # Exporting the df as csv file
        csv_file = rf'\\network_path\XY_Coordinate_Import\{date.today()}_xy_results.csv'
        original_df.to_csv(path_or_buf = csv_file,
                      sep='|',
                      header = False,
                      index = False
                      )

        # Deleting Original Excel File (Using Pathlib)
        excel_file.unlink()

    except:
        logging.warning('******===PROCESS FAILURE===******')
        logging.exception(Exception)
        send_email("tyler@gmail.com")

logging.info('Process Complete')
exit()
