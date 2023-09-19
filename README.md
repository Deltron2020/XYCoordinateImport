<h1>Importing XY Coordinates into Production CAMA Database</h1>

<h2>Tools Used</h2>

- <b>SQL</b>
- <b>Python</b>
- <b>PowerShell</b>
- <b>SSMS (Scheduled Job)</b>
- <b>Windows Task Manager</b>

<h2>Description</h2>

<b> Problem: </b> GIS professionals manually enter hundreds of XY coordinate values into the production CAMA application costing time and increasing chance of data entry errors. 
<br><br>
 <b> Solution: </b> Automate the entry process & batch import the XY coordinate values directly into the the CAMA database.
 <br><br>
<b> Quick Overview:  </b>
 
  - <b>Step 1:</b> The GIS professionals calculate and export the calculated XY coordinates into an Excel file that is placed in a network directory.
  - <b>Step 2:</b> A scheduled task runs weekly on a VM executing a PowerShell script that checks if the Excel file is present in the network directory. If the Excel file is present, the PowerShell script kicks off the Python script.
  - <b>Step 3:</b> The Python script simply reads the data in the Excel file to a Pandas dataframe, filters out any unwanted columns, and exports the dataframe as a csv file. Afterwards, the original Excel file is deleted.
  - <b>Step 4:</b> A scheduled job runs weekly via SSMS that executes a sql stored procedure. This stored procedure bulk inserts the data from the csv file into a temp table where the data is validated. After successful validation, the xy coordinate values are inserted into the production tables accessed by the CAMA application.

<p align="center">
<img src="https://i.imgur.com/v0lcnGF.png" height="75%" width="75%" alt="XY Process Flowchart"/>
</p>

<h2>Screenshots</h2>
*** For the sake of security, any email addresses, network paths, and anything deemed potentially sensitive will be removed from production code & screenshots *** .
<br />

<h3>Original Excel File with X/Y Coordinates</h3>
<p align="center">
<img src="https://i.imgur.com/zN8izXm.png" height="95%" width="95%" alt="XY Excel File"/>
</p>

<h3>Windows Task</h3>
<p align="center">
<img src="https://i.imgur.com/X0g4X4p.png" height="85%" width="85%" alt="XY Excel File"/>
</p>

<h3>SSMS Job</h3>
<p align="center">
<img src="https://i.imgur.com/Nw1ISAk.png" height="85%" width="85%" alt="XY Excel File"/>
</p>

<h3>CSV to CAMA</h3>
<p align="center">
<img src="https://i.imgur.com/zPx0t5i.png" height="85%" width="85%" alt="XY Excel File"/>
</p>

<h3>Email Notification</h3>
<p align="center">
<img src="https://i.imgur.com/xm0u7dn.png" height="85%" width="85%" alt="XY Excel File"/>
</p>


<h2>SQL Good Stuff</h2>

Links to other SQL scripts involved in this process:
- Exception Handling
- Does File Exist

- 

<!--
 ```diff
- text in red
+ text in green
! text in orange
# text in gray
@@ text in purple (and bold)@@
```
--!>
