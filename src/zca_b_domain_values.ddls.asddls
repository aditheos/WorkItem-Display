@AbapCatalog.sqlViewName: 'ZCABDOMVAL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ClientDependent: true
@VDM.viewType: #BASIC
@EndUserText.label: 'Domain Value List'
define view ZCA_B_DOMAIN_VALUES as select from dd07l as value
                               left outer join dd07t as _text
                                            on _text.domname = value.domname
                                           and _text.as4local = value.as4local
                                           and _text.as4vers = value.as4vers
                                           and _text.ddlanguage = $session.system_language
                                           and _text.domvalue_l = value.domvalue_l

{
    key value.domname    as DomainName,
    key value.domvalue_l as Value,
        _text.ddtext     as Text
}
