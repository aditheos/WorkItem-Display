@AbapCatalog.sqlViewName: 'ZCAIUSRNAMVH'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ClientDependent: true
@VDM.viewType: #BASIC
@ObjectModel:{
  dataCategory: #VALUE_HELP,
  representativeKey: 'VALUE'
}
@EndUserText.label: 'User Name Value Help'
define view ZCA_I_USERNAME_VH as select from usr21 as userSettings 
                             left outer join adrp  as _userInfo
                                          on _userInfo.persnumber = userSettings.persnumber {
    //ZCDS_B_USR_NAME
    key  bname as UserID,
    name_first as FirstName,
    name_last  as LastName,
    name_text  as FullName
}
