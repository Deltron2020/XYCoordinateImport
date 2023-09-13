<h1>Importing XY Coordinates into Production CAMA Database</h1>

<h2>Tools Used</h2>

- <b>SQL</b>
- <b>Python</b>
- <b>PowerShell</b>
- <b>SSMS (Scheduled Job)</b>
- <b>Windows Task Manager</b>

<h2>Description</h2>
<b>
 Problem: GIS professionals manually entered hundreds of XY coordinate values into production CAMA application costing time and increasing chance of data entry errors. 
 </b>
<br><br>
<b>
 Solution: Automated the entry process by batch importing the XY coordinate values directly into the the CAMA database.
 <br><br>
 Quick Overview:
 
  - Step 1: The GIS professionals calculate centroids for given parcels and export the calculated XY coordinates into an Excel file that is placed in a network directory.
  - Step 2: Scheduled Task runs weekly on a VM executing a PowerShell script that checks if the Excel file is present in the network directory. If the Excel file is present, the PowerShell script kicks off the Python script.
  - Step 3: The Python script simply reads the data in the Excel file to a Pandas dataframe, filters out any unwanted columns, and exports the dataframe as a csv file. Afterwards, the original Excel file is deleted.
  - Step 4: Scheduled Job runs weekly via SSMS that executes a sql stored procedure. This stored procedure bulk inserts the data from the csv file into a temp table where the data is validated. After successful validation, the xy coordinate data is inserted into the production tables accessed by the CAMA application.

</b>
<br />
<br />
The script is used in this demo where I setup Azure Sentinel (SIEM) and connect it to a live virtual machine acting as a honey pot.
We will observe live attacks (RDP Brute Force) from all around the world. I will use a custom PowerShell script to
look up the attackers Geolocation information and plot it on an Azure Sentinel Map!
<br />
<br />

<p align="center">
<img src="https://i.imgur.com/3d3CEwZ.png" height="85%" width="85%" alt="RDP event fail logs to iP Geographic information"/>
</p>

<h2>Attacks from China coming in; Custom logs being output with geodata</h2>

<p align="center">
<img src="https://i.imgur.com/LhDCRz4.jpeg" height="85%" width="85%" alt="Image Analysis Dataflow"/>
</p>

<h2>World map of incoming attacks after 24 hours (built custom logs including geodata)</h2>

<p align="center">
<img src="https://i.imgur.com/krRFrK5.png" height="85%" width="85%" alt="Image Analysis Dataflow"/>
</p>


<!--
 ```diff
- text in red
+ text in green
! text in orange
# text in gray
@@ text in purple (and bold)@@
```
--!>
