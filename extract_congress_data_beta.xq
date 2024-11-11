xquery version "3.1";

declare namespace saxon="http://saxon.sf.net/";
declare option saxon:output "indent=yes";

(: Definición de mensajes de error :)
let $ErrorName := <error>Congress name must not be empty</error>
let $ErrorPeriod := <error>Congress period is incomplete</error>
let $ErrorURL := <error>Congress URL is missing</error>

(: Importar los documentos XML :)
let $congressInfo := doc("congress_info.xml")
let $congressMembers := doc("congress_members_info.xml")

(: Obtener los datos principales del Congreso :)
let $congressName := string($congressInfo/api-root/congress/name)
let $congressNumber := string($congressInfo/api-root/congress/number)
let $startYear := string($congressInfo/api-root/congress/startYear)
let $endYear := string($congressInfo/api-root/congress/endYear)
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
      for $chamber in distinct-values(doc("congress_info.xml")//item/chamber)
      return
      (
        <chamber name="{normalize-space($chamber)}">
          <members>
              {
                (: Obtener todos los miembros que han pertenecido a esta cámara :)
                for $member in $congressMembers//member
                  let $bioguideId := string($member/bioguideId)
                  let $name := normalize-space($member/name)
                  let $state := normalize-space($member/state)
                  let $party := normalize-space($member/partyName)
                  let $imageUrl := normalize-space($member/depiction/imageUrl)
                  let $periods := 
                    for $term in $member/terms/item/item
                      where normalize-space(string($term/chamber)) = normalize-space($chamber)
                      let $startYear := normalize-space($term/startYear)
                      let $endYear := normalize-space($term/endYear)
                      return
                          (: Si no hay endYear, solo mostrar el startYear, sin 'to' :)
                          if ($endYear = "") then
                            <period from="{$startYear}">
                              {$startYear}
                            </period>
                          else
                            <period from="{$startYear}" to="{$endYear}">
                              {$startYear} - {$endYear}
                            </period>
                  return
                  if (some $term in $member/terms/item/item satisfies normalize-space(string($term/chamber)) = normalize-space($chamber)) then
                    <member name="{normalize-space($bioguideId)}">
                      <name>{$name}</name>
                      <state>{$state}</state>
                      <party>{$party}</party>
                      <image_url>{$imageUrl}</image_url>
                      <terms>
                        {$periods}
                      </terms>
                    </member>
                  else ()
              }
          </members>
          <sessions>
            {
              for $session in doc("congress_info.xml")//item[chamber = $chamber]
              return
              <session>
                  <number>{normalize-space($session/number)}</number>
                  <period>{normalize-space($session/startDate)} - {normalize-space($session/endDate)}</period>
                  <type>{normalize-space($session/type)}</type>
              </session>
            }
          </sessions>
        </chamber>
      )

    (: Generar la salida final que cumple con el XSD :)
    return
    <data xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:noNamespaceSchemaLocation="congress_data.xsd">
      <congress>
        <name number="{xs:integer($congressNumber)}">{$congressName}</name>
        <period from="{normalize-space($startYear)}" to="{normalize-space($endYear)}">{normalize-space(concat($startYear, "-", $endYear))}</period>
        <url>{normalize-space($url)}</url>
        <chambers>
          {$chambers}
        </chambers>
      </congress>
    </data>