select * from nash

-- Standardize the date fromat

select SaleDate, CONVERT(date, SaleDate)
from nash

update nash 
set SaleDate = CONVERT(date, SaleDate)

alter table nash
add SaleDateConverted Date;

select * from nash

update nash 
set SaleDateConverted = CONVERT(date,Saledate)

select SaleDate, CONVERT(date, SaleDate)
from nash


-- populate property address data 


select *
from nash
where PropertyAddress is null

-- self join

select a.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from nash a
join nash b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from nash a
join nash b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--- breaking out address into individual columns (address, city, state)

select PropertyAddress
from nash

-- , is the delimiter for addresses, and

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address 
, substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from nash

alter table nash
add propertySplitAddress NVarchar(255);

update nash
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table nash
add PropertySplitCity Nvarchar(255);

update nash
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select * from nash

select OwnerAddress
from nash

select 
PARSENAME(replace(OwnerAddress,',','.') , 3)
,PARSENAME(replace(OwnerAddress, ',' , '.') , 2)
,PARSENAME(replace(OwnerAddress, ',' , '.') , 1)
from nash;

alter table nash
add OwnerSplitAddress NVarchar(255);

update nash
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.') , 3)

alter table nash
add OwnerSplitCity NVarchar(255);

update nash
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',' , '.') , 2)

alter table nash
add OwnerSplitState NVarchar(255);

update nash
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',' , '.') , 1)

--select * from nash 

-- change Y and N to yes and no in Sold as Vacant field

select distinct (SoldAsVacant), COUNT(SoldAsVacant)
from nash
group by SoldAsVacant
order by 2


select SoldAsVacant,

update nash
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from nash

-- remove duplicates (not a usual thing to be done in SQL)


WITH rownumCTE as( 
select *,
ROW_NUMBER() over (
partition by ParcelID, 
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order by
	UniqueID
	)row_num
from nash
--order by ParcelID
)
--delete
select * 
from RowNumCTE
where ROW_NUM>1
--order by PropertyAddress

-- delete Unused columns

select * from nash

alter table nash
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table nash
drop column SaleDate

select * from nash