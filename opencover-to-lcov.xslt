<?xml version="1.0" ?>
<!--
MIT License

Copyright (c) 2026 Anirban Sarkar

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
-->
<xsl:transform version="3.0"
			   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" />

	<!-- Details about the LCOV format can be found at https://manpages.debian.org/jessie/lcov/geninfo.1.en.html. -->
	<xsl:template match="/">

		<!-- Sorts the BranchPoints by their uspid attribute, and writes them as the test name (TN). -->
		<xsl:text>TN:&#xA;</xsl:text>
		<xsl:variable name="sorted-branchpoint-uspids"
					  select="sort(descendant::BranchPoint/@uspid,(),function($id){($id/../../../../../../../Files/File[@uid=$id/../@fileid]/@fullPath,$id/../../../Name)})" />

		<!-- Groups each test by its fileid attribute and selects its children of types BranchPoint and SequencePoint respectively. -->
		<xsl:for-each-group group-by="@fileid"
							select="descendant::BranchPoint|descendant::SequencePoint">

			<!-- Sorts all file paths by the grouping key and writes them as the absolute paths of the source files (SF). -->
			<xsl:sort select="../../../../../../Files/File[@uid=current-grouping-key()]/@fullPath" />
			<xsl:text>SF:</xsl:text>
			<xsl:value-of select="../../../../../../Files/File[@uid=current-grouping-key()]/@fullPath" />

			<xsl:text>&#xA;</xsl:text>

			<!-- Groups all sequence points by the grouping key and writes them as the function names (FN) along with their respective lines numbers using their sl attributes. -->
			<xsl:for-each-group group-by="replace(../../Name,'^.*::(?:[gs]et_)?','')"
								select="current-group()[name()='SequencePoint']">
				<xsl:text>FN:</xsl:text>
				<xsl:value-of select="(min(current-group()/@sl),current-grouping-key())"
							  separator="," />

				<xsl:text>&#xA;</xsl:text>
			</xsl:for-each-group>

			<!-- Groups all sequence points by the grouping key and writes them as the function names (FNDA) along with their execution counts using their vc attributes. -->
			<xsl:for-each-group group-by="replace(../../Name,'^.*::(?:[gs]et_)?','')"
								select="current-group()[name()='SequencePoint']">
				<xsl:text>FNDA:</xsl:text>
				<xsl:value-of select="(max(current-group()/@vc),current-grouping-key())"
							  separator="," />

				<xsl:text>&#xA;</xsl:text>
			</xsl:for-each-group>

			<!-- The number of functions found. -->
			<xsl:text>FNF:</xsl:text>
			<xsl:value-of select="count(distinct-values(current-group()/../../Name))" />
			<xsl:text>&#xA;</xsl:text>

			<!-- The number of functions hit. -->
			<xsl:text>FNH:</xsl:text>
			<xsl:value-of select="count(distinct-values(current-group()/../..[@visited='true']/Name))" />
			<xsl:text>&#xA;</xsl:text>

			<!-- Fill list of branch information (BRDA). -->
			<xsl:for-each select="current-group()[name()='BranchPoint']">
				<xsl:sort select="../../Name" />
				<xsl:text>BRDA:</xsl:text>
				<xsl:value-of select="(@sl,@sl,index-of($sorted-branchpoint-uspids,string(@uspid))-1,replace(@vc,'^0$','-'))"
							  separator="," />

				<xsl:text>&#xA;</xsl:text>
			</xsl:for-each>

			<!-- The number of branches found. -->
			<xsl:text>BRF:</xsl:text>
			<xsl:value-of select="count(current-group()[name()='BranchPoint'])" />

			<xsl:text>&#xA;</xsl:text>

			<!-- The number of branches hit. -->
			<xsl:text>BRH:</xsl:text>
			<xsl:value-of select="count(current-group()[name()='BranchPoint' and @vc>0])" />

			<xsl:text>&#xA;</xsl:text>

			<!-- Fill list of execution information (DA). -->
			<xsl:for-each select="current-group()[name()='SequencePoint']">
				<xsl:sort select="@sl" />
				<xsl:text>DA:</xsl:text>
				<xsl:value-of select="(@sl,@vc)"
							  separator="," />

				<xsl:text>&#xA;</xsl:text>
			</xsl:for-each>

			<!-- The number of lines hit. -->
			<xsl:text>LH:</xsl:text>
			<xsl:value-of select="count(current-group()[name()='SequencePoint' and @vc>0])" />

			<xsl:text>&#xA;</xsl:text>

			<!-- The number of instrumented lines. -->
			<xsl:text>LF:</xsl:text>
			<xsl:value-of select="count(current-group()[name()='SequencePoint'])" />

			<xsl:text>&#xA;</xsl:text>

			<xsl:text>end_of_record</xsl:text>

			<xsl:if test="position()!=last()">
				<xsl:text>&#xA;</xsl:text>
			</xsl:if>
		</xsl:for-each-group>
	</xsl:template>
</xsl:transform>
