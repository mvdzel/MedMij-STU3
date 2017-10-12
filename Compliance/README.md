# ZIB-Compliance

See 
[https://www.registratieaandebron.nl/middelen/downloads/](https://www.registratieaandebron.nl/middelen/downloads/) and then scroll down to "Zib-compliance" for background information.

This scripts will populate most of the ZIB-Compliance spreadsheet columns based on the Structure Definitions XML and MAX version of the Zorginformatiebouwstenen.

## Validate(-v2).xslt

This script works on the differential, so it cannot check all the way back to the FHIR Resource level.
Anyhow this is a very useful for checking the mappings. 

## Validate-snapshots-v3.xslt

Steps:
1. Create the MedMij-all-in-one.xml with snapshots expanded using FhirConsole
	1. Pull MedMij-STU3 from git > c:\eclipse workspace\MedMij-STU3
	1. Call hidden feature of FhirConsole "FhirConsole mz" - N.B. currently expects differentials at E:\MedMij-STU3, output folder E:\MedMij-STU3-snapshots and C:\VisualStudio Projects\fhir-net-api\src\Hl7.Fhir.Specification\specification.zip
	1. cd c:\temp\MedMij-STU3\snapshot
	1. type zib-\*.xml nl-\*.xml > MedMij-all-in-one-snapshots.xml
	1. add root-tag to 1.4 xml file (\<root\> as first line and \</root\> as last line
1. Create the ZIB MAX XML
	1. You need the eap version of the ZIB's + Sparx Enterprise Architect + HL7 MAX Extension
1. Run the xslt
1. Update output of xslt in the spreadsheet
	1. open spreadsheet, developer tab, import output of xslt

N.B. In the tab "BgZ" is the BgZ indicator of each ZIB/part

TODO: Check Coding

