## ZIB-Compliance

See 
[https://www.registratieaandebron.nl/middelen/downloads/](https://www.registratieaandebron.nl/middelen/downloads/) and then scroll down to "Zib-compliance" for background information.

This scripts will populate most of the ZIB-Compliance spreadsheet columns based on the Structure Definitions XML and MAX version of the Zorginformatiebouwstenen.

-- Validate(-v2).xslt --

This script works on the differential, so it cannot check all the way back to the FHIR Resource level.
Anyhow this is a very useful for checking the mappings. 
-----------
-- Validate-snapshots-v3.xslt --

Steps:
# 1 Create the MedMij-all-in-one.xml with snapshots expanded using FhirConsole
# 2 Create the ZIB MAX XML
# 3 Run the xslt
# 4 Update output of xslt in the spreadsheet

1.1 Pull MedMij-STU3 from git > c:\eclipse workspace\MedMij-STU3
1.2 Call hidden feature of FhirConsole "FhirConsole mz"
1.3 cd c:\temp\MedMij-STU3\snapshot
1.4 type zib-*.xml nl-*.xml > MedMij-all-in-one-snapshots.xml
1.5 add <root></root>-tag to 1.4 xml file
2.1 You need the eap version of the ZIB's + Sparx Enterprise Architect + HL7 MAX Extension
3.1 run xslt
4.1 open spreadsheet, developer tab, import output of xslt
N.B. In the tab "BgZ" is the BgZ indicator of each ZIB/part

TODO: Check cardinality, Coding

