xquery version "3.1";

declare namespace saxon="http://saxon.sf.net/";
declare option saxon:output "indent=yes";

(: Definición de mensajes de error :)
let $ErrorName := <error>Congress name must not be empty</error>
let $ErrorPeriod := <error>Congress period is incomplete</error>
let $ErrorURL := <error>Congress URL is missing</error>

(: Importar los documentos XML :)
let $congressInfo := doc("/Users/martundl/docsXML/2do_parcial/congress_info.xml")
let $congressMembers := doc("/Users/martundl/docsXML/2do_parcial/congress_members_info.xml")

(: Obtener los datos principales del Congreso :)
let $congressName := string($congressInfo/api-root/congress/name)
let $congressNumber := string($congressInfo/api-root/congress/number)
let $startYear := string($congressInfo/api-root/congress/startDate)
let $endYear := string($congressInfo/api-root/congress/endDate)
let $url := string($congressInfo/api-root/congress/url)

(: Validar datos obligatorios y recolectar errores :)
let $errors := ()
let $errors := if ($congressName = "") then ($errors, $ErrorName) else $errors
let $errors := if ($startYear = "" or $endYear = "") then ($errors, $ErrorPeriod) else $errors
let $errors := if ($url = "") then ($errors, $ErrorURL) else $errors

(: Si hay errores, devolver un XML solo con errores :)
return
  if (count($errors) > 0) then
    <data xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:noNamespaceSchemaLocation="congress_data.xsd">
      {$errors}
    </data>
  else
    (: Si no hay errores, construir el XML con la información del congreso y sus cámaras :)
    let $chambers := 
      for $chamberName in distinct-values($congressInfo/sessions/item/chamber)
      let $chamberMembers := 
        for $member in $congressMembers
        where some $term in $member/terms/item/item/chamber satisfies ($term = $chamberName)
        return
          <member bioguideId="{string($member/bioguideId)}">
            <name>{string($member/name)}</name>
            <state>{string($member/state)}</state>
            <party>{string($member/partyName)}</party>
            <image_url>{string($member/depiction/imageUrl)}</image_url>
            <period from="{string($member/terms/item/item/startYear)}" 
                    to="{string($member/terms/item/item/endYear)}" />
          </member>
      let $chamberSessions := 
        for $session in $congressInfo/sessions/item
        where string($session/chamber) = $chamberName
        return
          <session>
            <number>{string($session/number)}</number>
            <period from="{string($session/startDate)}" 
                    to="{string($session/endDate)}" />
            <type>{string($session/type)}</type>
          </session>
      return
        <chamber>
          <name>{$chamberName}</name>
          <members>{$chamberMembers}</members>
          <sessions>{$chamberSessions}</sessions>
        </chamber>
      
    (: Generar la salida final que cumple con el XSD :)
    return
    <data xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:noNamespaceSchemaLocation="congress_data.xsd">
      <congress>
        <name number="{$congressNumber}">{$congressName}</name>
        <period from="{$startYear}" to="{$endYear}">{$startYear} - {$endYear}</period>
        <url>{$url}</url>
        <chambers>
          {$chambers}
        </chambers>
      </congress>
    </data>


