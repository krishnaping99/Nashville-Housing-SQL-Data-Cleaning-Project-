/* LO1 - Standardizing Sale Date Format */

-- Converting SaleDate column from Date/Time Format to Standard Date format and upgrading the table 

Update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)

select Saledate from dbo.nashvillehousing


/* L02 - Populating NULL values in Property Address column to their respective real address' */

-- Checking NULL entries in Property Address column

select * from dbo.nashvillehousing
where propertyaddress is NULL

/*Checking NULL values in PropertyAdress' column of entries with the same ParcelID, but different UniqueID,
 to identify proper NULL values to be populated */

 select originalTB.ParcelID, originalTB.PropertyAddress, cloneTB.ParcelID, cloneTB.PropertyAddress 
 from dbo.nashvillehousing as originalTB
 join dbo.nashvillehousing as cloneTB
	on originalTB.ParcelID = cloneTB.ParcelID
	and originalTB.UniqueID != cloneTB.UniqueID
 where originalTB.PropertyAddress is NULL

 -- Populatinf these NULL Values with their relevant addresses
 select originalTB.ParcelID, originalTB.PropertyAddress, cloneTB.ParcelID, cloneTB.PropertyAddress , ISNULL(originalTB.PropertyAddress,cloneTB.PropertyAddress)
 from dbo.nashvillehousing as originalTB
 join dbo.nashvillehousing as cloneTB
	on originalTB.ParcelID = cloneTB.ParcelID
	and originalTB.UniqueID != cloneTB.UniqueID
 where originalTB.PropertyAddress is NULL

 -- updating the table to include populated PropertyAddress column
 update originalTB
 Set PropertyAddress = ISNULL(originalTB.PropertyAddress,cloneTB.PropertyAddress)
 from dbo.nashvillehousing as originalTB
 join dbo.nashvillehousing as cloneTB
	on originalTB.ParcelID = cloneTB.ParcelID
	and originalTB.UniqueID != cloneTB.UniqueID
 where originalTB.PropertyAddress is NULL


 /* L03 - Splitting Property Address into its individual base columns */
 
 select PropertyAddress from [dbo].[NashvilleHousing]

 -- Using Substrings and Char Index to split PropertyAddress into its components
 select 
 substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address,
 substring(PropertyAddress, Charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) Address
 from [dbo].[NashvilleHousing]

 -- Updating NashvilleHousing table to include the split address columns
 alter table NashvilleHousing
 add PropertySplitAddress Nvarchar(255);

 update NashvilleHousing
 set PropertySplitAddress = substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1)

 alter table NashvilleHousing
 add PropertySplitCity Nvarchar(255);

 update NashvilleHousing
 set PropertySplitCity = substring(PropertyAddress, Charindex(',', PropertyAddress) +1, LEN(PropertyAddress))

 -- Splitting Owner address down using parsename
 select PARSENAME(replace(OwnerAddress, ',', '.'), 1)
 from [dbo].[NashvilleHousing]

 -- Updating NashvilleHousing table to include the split owner adress column
 alter table NashvilleHousing
 add OwnerSplitState Nvarchar(255);

 update NashvilleHousing
 set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


 
 /* L04 - Removing Duplicates by using CTEs */

 WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
from [dbo].[NashvilleHousing]
)
delete 
from RowNumCTE
where row_num > 1



/* L05 - Removing Unused columns */

Alter table [dbo].[NashvilleHousing]
drop column TaxDistrict



select * from [dbo].[NashvilleHousing]