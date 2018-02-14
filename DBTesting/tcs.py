# coding=utf-8
# !
# -------------------------------------------------------------------------------
# Description :Test cases configuration
#
# Pre-requests: json
# History     :
# DATE        AUTHOR          DESCRIPTION
# ----------  ----------      ----------------------------------------------------
# 01/16/2018  - eliu2         - created
#
# @CopyRight  :
# -------------------------------------------------------------------------------
from SPTest.testcases import assert_sp
from SPTest.testcases import assert_var_sp
"""
name:a function name
timeout:time out
args:a tuple, function parameters
"""
# t =[
#     dict(name=assert_var_sp, timeout=None,
#          args=('dbo.DynamicSearch_LicenseTopLevel_BY_eliu2', 'dbo.DynamicSearch_LicenseTopLevel',
#                "@SalesDateFrom='4/20/2017',@SalesDateTo ='4/21/2017'")),
#     dict(name=assert_var_sp, timeout=None,
#          args=('dbo.DynamicSearch_LicenseTopLevel_BY_eliu2', 'dbo.DynamicSearch_LicenseTopLevel',
#                "@ItemNumber='1110'")),
#     dict(name=assert_var_sp, timeout=None,
#          args=('dbo.DynamicSearch_LicenseTopLevel_BY_eliu2', 'dbo.DynamicSearch_LicenseTopLevel',
#                "@SalesDateFrom='1/5/2017',@SalesDateTo ='1/5/2017',@DocumentNumber='D-0021975947-4'")),
# ]

# t = [dict(name=assert_var_sp, timeout=None,
#           args=('dbo.LicenseTopLevel_Search_BY_eliu2', 'dbo.LicenseTopLevel_Search',
#                 " @SalesDateFrom= '04/20/2017', @SalesDateTo  = '04/21/2017', @SalesClerkUserName= 'a', @TransactionID= 1000, @LicenseID= 1000, @DocumentNumber= '1001', @HasReprint= 1, @HasDuplicate = 1, @LicenseStatusCodeID= 1, @IsExpired= 1, @LicenseAncillaryDataKeyName= 'name', @LicenseAncillaryDataValue  = 'val', @HuntCode = '20', @OutletNumber = '2100', @OutletZipCode= '12345', @OutletCityName= 'newyok', @OutletCountyID= 1, @OutletStateID= 2, @ItemYear = 3, @ItemNumber= '2000', @RootItemNumberID  = 1, @ItemClassID  = 2, @ItemCategoryID= 3, @ItemSubcategoryID = 4, @ItemTypeID= 5, @MasterHuntTypeID  = 6, @LEPermitTypeID= 7, @IsEntitlement= 1, @UseCustomerCriteria= 0, @CustomerTypeID= 2, @IdentityTypeCategoryID = 4, @IdentityTypeID= 3, @IdentityValue= '24', @PhysicalCityID= 4, @PhysicalStateID= 5, @PhysicalCountyID  = 6, @PhysicalZipCode= '2323', @PhysicalIsInternationalAddress = 1, @IsCAResident = 1, @FirstName= 'er', @LastName = 'sf', @Gender= '1', @BusinessName = 'xx', @VesselName= 'nanm'")),]


# t = [dict(name=assert_var_sp, timeout=None,
#           args=('dbo.LicenseTopLevel_Search_BY_eliu2', 'dbo.LicenseTopLevel_Search',
#                 "@SalesDateFrom='4/20/2017',@SalesDateTo ='4/21/2017',@UseCustomerCriteria =1,@CustomerTypeID=1,@IdentityValue='1051298422'")),
#      dict(name=assert_var_sp, timeout=30,
#           args=('dbo.LicenseTopLevel_Search_BY_eliu2', 'dbo.LicenseTopLevel_Search',
#                 "@ItemNumber='1110',@UseCustomerCriteria =1,@CustomerTypeID=1,@IdentityValue='1051298422'")),
#      dict(name=assert_var_sp, timeout=40,
#           args=('dbo.LicenseTopLevel_Search_BY_eliu2', 'dbo.LicenseTopLevel_Search',
#                 "@SalesDateFrom='1/5/2017',@SalesDateTo ='1/5/2017',@UseCustomerCriteria =1,@CustomerTypeID=1,@DocumentNumber='D-0021975947-4',@LastName='P'")),
#      ]


# t = [dict(name=assert_sp, timeout=None, args=('dbo.rpt_internetsales_BY_eliu2', 'dbo.rpt_internetsales', (1, 2017,))),
#      dict(name=assert_sp, timeout=None, args=('dbo.rpt_internetsales_BY_eliu2', 'dbo.rpt_internetsales', (2, 2017,))),
# dict(name=assert_sp, timeout=None, args=('dbo.rpt_internetsales_BY_eliu2', 'dbo.rpt_internetsales', (3, 2017,))),
# dict(name=assert_sp, timeout=None, args=('dbo.rpt_internetsales_BY_eliu2', 'dbo.rpt_internetsales', (4, 2017,))),
# dict(name=assert_sp, timeout=None, args=('dbo.rpt_internetsales_BY_eliu2', 'dbo.rpt_internetsales', (5, 2017,))),
# dict(name=assert_sp, timeout=None, args=('dbo.rpt_internetsales_BY_eliu2', 'dbo.rpt_internetsales', (7, 2017,))),
# dict(name=assert_sp, timeout=None, args=('dbo.rpt_internetsales_BY_eliu2', 'dbo.rpt_internetsales', (8, 2017,))),
# dict(name=assert_sp, timeout=None, args=('dbo.rpt_internetsales_BY_eliu2', 'dbo.rpt_internetsales', (9, 2017,))),
# dict(name=assert_sp, timeout=None, args=('dbo.rpt_internetsales_BY_eliu2', 'dbo.rpt_internetsales', (10, 2017,))),
# dict(name=assert_sp, timeout=None, args=('dbo.rpt_internetsales_BY_eliu2', 'dbo.rpt_internetsales', (11, 2017,))),
# dict(name=assert_sp, timeout=None, args=('dbo.rpt_internetsales_BY_eliu2', 'dbo.rpt_internetsales', (12, 2017,))),
#      ]

t = [dict(name=assert_sp, timeout=None, args=('dbo.rpt_CurrentInventoryListing_BY_eliu2','dbo.rpt_CurrentInventoryListing', (310001, None,))),
     ]
     # dict(name=assert_sp, timeout=25, args=('dbo.rpt_EventNoticeForCreditBalance_BY_eliu2','dbo.rpt_EventNoticeForCreditBalance', ())),
     # dict(name=assert_sp, timeout=None, args=('dbo.rpt_PercentageOfRevenue_BY_eliu2', 'dbo.rpt_PercentageOfRevenue', ('01/01/2017', '01/31/2017', 20,))),
     # dict(name=assert_sp, timeout=None, args=('dbo.rpt_StatementDetailTotals_BY_eliu2', 'dbo.rpt_StatementDetailTotals', (200003, '200003-089', '10/06/2015', 84,))),
     # dict(name=assert_sp, timeout=None, args=('dbo.rpt_TransactionDetailByAgent_BY_eliu2', 'dbo.rpt_TransactionDetailByAgent', ('200003-089', 200003, None, '01/01/2016', '09/30/2016', None,))),
     # ]

def test_cases():
    return t

