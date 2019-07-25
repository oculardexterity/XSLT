<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jc="http://james.blushingbunny.net/ns.html"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="jc"
    version="3.0">
    
    <xsl:output indent="yes"/>
    
    
    <xsl:template match="processing-instruction()"/>
    
    <xsl:template match="/">
        
        <!-- Capture the page-splitting output -->
        <xsl:variable name="output">
            <xsl:copy>
                <xsl:apply-templates />
            </xsl:copy>
        </xsl:variable>
       
        <!-- Get a specific page and apply pass3 templates -->
        <xsl:apply-templates select="$output//text[@type='transcription']//jc:page[@n='25']" mode="pass3"/>
    </xsl:template>
    
   
    <!-- This works: <p> becomes <PARAGRAPH> -->
    <xsl:template mode="pass3" match="//p">
        <PARAGRAPH><xsl:apply-templates/></PARAGRAPH>
    </xsl:template>
    
    <!-- This doesn't work... ?
        Very possible I've done something wrong, but then why does
        the <PARAGRAPH> template above work? Surely both work or none?
        -->
    <xsl:template mode="pass3" match="//persName">
        <PERSON><xsl:value-of select="."/></PERSON>
    </xsl:template>
    
    
    
    
    


    <xsl:template match="teiHeader">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    
    <xsl:template match="TEI|teiCorpus|group|text">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*|comment()|text()"/>
        </xsl:copy>
    </xsl:template>
    
    
    
    <xsl:template match="text/body|text/back|text/front">
        <xsl:variable name="pages">
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:apply-templates
                    select="*|comment()|text()"/>
            </xsl:copy>
        </xsl:variable>
        <xsl:for-each select="$pages">
            <xsl:apply-templates  mode="pass2"/>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- first (recursive) pass. look for <pb> elements and group on them -->
    <xsl:template match="comment()|@*|text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:call-template name="checkpb">
            <xsl:with-param name="eName" select="local-name()"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="pb">
        <pb>
            <xsl:copy-of select="@*"/>
        </pb>
    </xsl:template>
    
    <xsl:template name="checkpb">
        <xsl:param name="eName"/>
        <xsl:choose>
            <xsl:when test="not(.//pb)">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="pass">
                    <xsl:call-template name="groupbypb">
                        <xsl:with-param name="Name" select="$eName"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:for-each select="$pass">
                    <xsl:apply-templates/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="groupbypb">
        <xsl:param name="Name"/>
        <xsl:for-each-group select="node()" group-starting-with="pb">
            <xsl:choose>
                <xsl:when test="self::pb">
                    <xsl:copy-of select="."/>
                    <xsl:element name="{$Name}">
                        <xsl:attribute name="rend">CONTINUED</xsl:attribute>
                        <xsl:apply-templates select="current-group() except ."/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="{$Name}">
                        <xsl:for-each select="..">
                            <xsl:copy-of select="@*"/>
                            <xsl:apply-templates select="current-group()"/>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
    
    <!-- second pass. group by <pb> (now all at top level) and wrap groups
       in <page> -->
    <xsl:template match="*" mode="pass2">
        <xsl:copy>
            <xsl:apply-templates select="@*|*|comment()|text()" mode="pass2"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="comment()|@*|text()" mode="pass2">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="*[pb]" mode="pass2" >
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="*" group-starting-with="pb">
                <xsl:choose>
                    <xsl:when test="self::pb">
                        <page xmlns="http://james.blushingbunny.net/ns.html"> 
                            <xsl:copy-of select="@*"/>
                            <xsl:copy-of select="current-group() except ."/>
                        </page>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
