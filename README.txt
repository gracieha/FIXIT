FIXIT Monthly Report Process

1.  Make a new dropbox folder for this month
2.  Make a new monthly data folder for this month, and then:
    a. Visually check the latest error flags spreadsheet, fix if necessary,
       and move to the monthly data folder
    b. Get this month's MCCDB excel file from the METRC Reporting dropbox folder
       and place into the monthly data folder
    c. Get the registry and place into monthly data folder
    d. Get the log file and place into the monthly data folder
3.  Get this months Redcap data files from the METRC Reporting dropbox folder
    and place into FIXIT REDCap data folder
4.  Update the import_REDCap macro with the new input sas code
5.  Add code to process errors for queries that previously did not have any errors
    to process
6.  Update the date in the 0_setup.sas program, and run
7.  Update the announcements in the monthlyReport.rnw file
8.  Update the date in the monthlyReport.r program, and test-run over the 'ALL' facility
9.  Check the result and fix any problems 
10. Update the shout-outs based on the test-run
11. Run monthlyReport.r on all facilities
12. Update the miscellanea file with any needed edits
13. Update PivotalTracker to notify SM that report is ready
14. Run toTony.sas to get the STREAM info to Tony
15. Run toGrace.sas to get data to Grace for her additional items

