@AbapCatalog.sqlViewName: 'ZCAIWFSTATUSVH'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@ClientDependent: true
@VDM.viewType: #BASIC
@ObjectModel:{
  dataCategory: #VALUE_HELP,
  representativeKey: 'VALUE'
}
@EndUserText.label: 'Workflow Status Value Help'
define view ZCA_I_WFSTATUS_VH as select from ZCX_B_DOMAIN_VALUES as domval {
    //domval
    key Value,
        Text
} where DomainName = 'SWW_WISTAT'
