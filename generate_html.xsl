<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <html>
            <head>
                <title>Congress Data</title>
            </head>
            <body>
                <!-- CONTENIDO DE LA PAGINA (Item A)-->
                <h1 align="center">
                    <xsl:value-of select="data/congress/name"/>
                </h1>
                <h3 align="center">
                    From <xsl:value-of select="data/congress/period/@from"/> to <xsl:value-of select="data/congress/period/@to"/>
                </h3>
                <hr/> <!-- LINEA HORIZONTAL-->

                <!-- CAMARAS (Item B)-->
                <xsl:for-each select="data/congress/chambers/chamber">
                    <h2 align="center">
                        <xsl:value-of select="name"/>
                    </h2>
                    <h4 align="center">Members</h4>

                    <!-- TABLA DE MIEMBROS-->
                    <table border="1" align="center">
                        <thead bgcolor="yellow">
                            <tr>
                                <th>Name</th>
                                <th>State</th>
                                <th>Party</th>
                                <th>Period</th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:for-each select="members/member">
                                <xsl:sort select="name" order="ascending"/>
                                <tr>
                                    <td><xsl:value-of select="name"/></td>
                                    <td><xsl:value-of select="state"/></td>
                                    <td><xsl:value-of select="party"/></td>
                                    <td>
                                        From <xsl:value-of select="period/@from"/> to <xsl:value-of select="period/@to"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>

                    <!-- Tabla de sesiones -->
                    <h4 align="center">Sessions</h4>
                    <table border="1" align="center">
                        <thead bgcolor="yellow">
                            <tr>
                                <th>Number</th>
                                <th>Type</th>
                                <th>Period</th>
                            </tr>
                        </thead>
                        <!-- TABLA DE SESIONES-->
                        <tbody>
                            <xsl:for-each select="sessions/session">
                                <tr>
                                    <td><xsl:value-of select="number"/></td>
                                    <td><xsl:value-of select="type"/></td>
                                    <td>
                                        From <xsl:value-of select="period/@from"/> to <xsl:value-of select="period/@to"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>

                    <hr/>
                </xsl:for-each>

            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
