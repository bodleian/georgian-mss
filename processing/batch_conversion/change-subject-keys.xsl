<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8"/>
    
    <xsl:variable name="newline" select="'&#10;'"/>
    
    <xsl:variable name="subjects" select="document('../../authority/subjects_base.xml')//tei:TEI/tei:text/tei:body/tei:list/tei:item"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
        <xsl:value-of select="$newline"/>
    </xsl:template>
    
    <xsl:template match="processing-instruction('xml-model')">
        <xsl:value-of select="$newline"/>
        <xsl:copy/>
        <xsl:if test="preceding::processing-instruction('xml-model')"><xsl:value-of select="$newline"/></xsl:if>
    </xsl:template>
    
    <xsl:template match="text()|comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:copy></xsl:template>
    
    <xsl:template match="tei:term[@key] | tei:placeName[@key]">
        <xsl:copy>
            <xsl:copy-of select="@*[not(name()=('key','target', 'ref'))]"/>
            <xsl:variable name="key" as="xs:string" select="@key"/>
            <xsl:variable name="matchingauthorityentries" select="$subjects[@xml:id = $key]"/>
            <xsl:choose>
                <xsl:when test="count($matchingauthorityentries) eq 1">
                    <xsl:attribute name="key">
                        <xsl:text>subject_</xsl:text>
                        <xsl:value-of select="tokenize($matchingauthorityentries[1]/tei:note[1]/tei:list[1]/tei:item[1]/tei:ref[1]/@target, '/')[last()]"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>Cannot find a single matching key</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>