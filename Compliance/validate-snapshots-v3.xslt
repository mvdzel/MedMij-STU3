<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:max="http://www.umcg.nl/MAX"
	xmlns:fhir="http://hl7.org/fhir">

	<xsl:output encoding="utf-8" indent="yes" method="xml"/>
	
<!--
  ZIB 2017-1 DCM::ConceptId tag instead of DCM::DefinitionCode.startsWith NL-CM: as in 2016 version
  v3.1 added zib_element_card, fhir_element_card, equal_card
 -->
	
	<xsl:variable name="zibs" select="document('Zorginformatiebouwstenen 2017-1.max')"/>
	<xsl:variable name="zibgens" select="$zibs//relationships/relationship[type='Generalization']"/>
	<xsl:variable name="zibaggs" select="$zibs//relationships/relationship[type='Aggregation']"/>
	<xsl:variable name="zib_datatypes">
		<datatype id="7887" name="TS" fhir="dateTime"/>
		<datatype id="7906" name="CD" fhir="Coding"/>
		<datatype id="7895" name="ST" fhir="string"/>
		<datatype id="7891" name="PQ" fhir="Quantity"/>
		<datatype id="7892" name="BL" fhir="boolean"/>
		<datatype id="7888" name="INT" fhir="integer"/>
		<datatype id="7886" name="CO" fhir="Coding"/>
		<datatype id="7885" name="ED" fhir="base64Binary"/>
		<datatype id="7889" name="II" fhir="Identifier"/>
		<datatype id="7903" name="ANY" fhir="Element"/>		
	</xsl:variable>
	<xsl:variable name="datatype_mapping">
		<mapping zib="reference" fhir="Reference"/>
		<mapping zib="PQ" fhir="Quantity"/>
		<mapping zib="PQ" fhir="Ratio"/>
		<mapping zib="CO" fhir="CodeableConcept"/>
		<mapping zib="CD" fhir="CodeableConcept"/>
		<mapping zib="CD" fhir="Coding"/>
		<mapping zib="CD" fhir="code"/>
		<mapping zib="ST" fhir="string"/>
		<mapping zib="ST" fhir="Annotation"/>
		<mapping zib="TS" fhir="dateTime"/>
		<mapping zib="TS" fhir="date"/>
		<mapping zib="BL" fhir="boolean"/>
		<mapping zib="II" fhir="Identifier"/>
		<mapping zib="ED" fhir="Attachement"/>
		<mapping zib="" fhir=""/> <!-- for rootconcept or containers -->
	</xsl:variable>
	
	<xsl:template match="/">
		<xsl:variable name="medmij" select="."/>
		<compliance>
		<!-- For each ZIB -->
		<xsl:for-each select="$zibs/max:model/objects/object[stereotype='DCM']">
			<xsl:variable name="zib" select="."/>
			<xsl:variable name="zibname" select="tag[@name='DCM::Name']/@value"/>
			<xsl:variable name="zibpkgid" select="id"/>
			<xsl:variable name="impkgid" select="$zibs/max:model/objects/object[parentId=$zibpkgid and name='Information Model']/id"/>
			<!-- For each concept in the ZIB -->
			<xsl:for-each select="$zibs/max:model/objects/object[parentId=$impkgid and type='Class' and tag/@name='DCM::ConceptId']">
				<xsl:variable name="zibelement" select="."/>
				<xsl:variable name="zib_datatype">
					<xsl:variable name="zib_datatype_id" select="$zibgens[sourceId=$zibelement/id]/destId"/>
					<xsl:variable name="zib_reference" select="$zibelement/tag[@name='DCM::ReferencedDefinitionCode']/@value"/>
					<xsl:choose>
						<xsl:when test="exists($zib_reference)">reference</xsl:when>
						<xsl:when test="$zibelement/stereotype='rootconcept'">root</xsl:when>
						<xsl:when test="$zibelement/stereotype='container'">container</xsl:when>
						<xsl:otherwise><xsl:value-of select="$zib_datatypes/datatype[@id=$zib_datatype_id]/@name"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="zibelementcard" select="$zibaggs[sourceId=$zibelement/id]/sourceCard"/>
				
				<xsl:variable name="zibelementid" select="$zibelement/tag[@name='DCM::ConceptId']/@value"/>
				<xsl:variable name="fhirelement" select="$medmij//fhir:snapshot/fhir:element[fhir:mapping/fhir:map/@value=$zibelementid]"/>
				<xsl:variable name="fhirname" select="$fhirelement/../../fhir:name/@value"/>
				<xsl:variable name="fhirelementexists">
					<xsl:choose>
						<xsl:when test="exists($fhirelement)">TRUE</xsl:when>
						<xsl:otherwise>FALSE</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="fhirdatatype" select="$fhirelement/fhir:type/fhir:code/@value"/>
				<xsl:variable name="fhirelementalias" select="$fhirelement/fhir:alias/@value"/>
				<xsl:variable name="fhirelementcard" select="concat($fhirelement/fhir:min/@value,'..',$fhirelement/fhir:max/@value)"/>
				<xsl:variable name="equal_name">
					<xsl:choose>
						<xsl:when test="$fhirelementexists='TRUE'">
							<xsl:choose>
								<xsl:when test="compare($zibelement/name, $fhirelementalias)=0">TRUE</xsl:when>
								<xsl:otherwise>FALSE</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>&#160;</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="equal_datatype">
					<xsl:choose>
						<xsl:when test="$zib_datatype!='' and $fhirelementexists='TRUE'">
							<xsl:choose>
								<xsl:when test="exists($datatype_mapping/mapping[@zib=$zib_datatype and @fhir=$fhirdatatype])">TRUE</xsl:when>
								<xsl:otherwise>FALSE</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>&#160;</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="equal_card">
					<!-- Don't test card for ZIB root -->
					<xsl:choose>
						<xsl:when test="$zib_datatype!='root' and $fhirelementexists='TRUE'">
							<xsl:choose>
								<xsl:when test="compare($zibelementcard, $fhirelementcard)=0">TRUE</xsl:when>
								<xsl:when test="compare($zibelementcard,'1')=0 and compare($fhirelementcard,'1..1')=0">TRUE</xsl:when>
								<xsl:when test="compare($zibelementcard,'')=0 and compare($fhirelementcard,'1..1')=0">TRUE</xsl:when>
								<xsl:otherwise>FALSE</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>&#160;</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<zib-compliance>
					<xsl:attribute name="zib_name" select="$zibname"/>
					<xsl:attribute name="zib_element_name" select="$zibelement/name"/>
					<xsl:attribute name="zib_element_id" select="$zibelementid"/>
					<xsl:attribute name="zib_element_datatype" select="$zib_datatype"/>
					<xsl:attribute name="zib_element_card" select="$zibelementcard"/>
					<xsl:attribute name="mapping_count" select="count($fhirelement)"/>
					<xsl:attribute name="fhir_name" select="$fhirname"/>
					<xsl:attribute name="fhir_element_alias" select="$fhirelementalias"/>
					<xsl:attribute name="fhir_element_path" select="$fhirelement/fhir:path/@value"/>
					<xsl:attribute name="fhir_element_datatype" select="$fhirdatatype"/>
					<xsl:attribute name="fhir_element_card" select="$fhirelementcard"/>
					
					<xsl:attribute name="exists_fhir_element" select="$fhirelementexists"/>
					<xsl:attribute name="equal_datatype" select="$equal_datatype"/>
					<xsl:attribute name="equal_card" select="$equal_card"/>
					<xsl:attribute name="equal_name" select="$equal_name"/>
					<xsl:attribute name="equal_meaning"/>
					<xsl:attribute name="equal_valueset"/>
				</zib-compliance>
			</xsl:for-each>
		</xsl:for-each>
		</compliance>		
	</xsl:template>
	
</xsl:stylesheet>