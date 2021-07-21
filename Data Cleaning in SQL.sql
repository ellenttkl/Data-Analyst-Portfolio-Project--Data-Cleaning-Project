/*

Cleaning data in SQL Queries

*/

Select * 
From [dbo].[NashvilleHousing]

--------------------------------------------------------------------------------------------------------------

--Standarize Date Format

Alter Table NashvilleHousing
add SaleDateConverted Date

Update NashvilleHousing
set SaleDateConverted = Convert(Date,SaleDate)

Select SaleDateConverted,Convert(Date,SaleDate)
From [dbo].[NashvilleHousing]

------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data


Select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [dbo].[NashvilleHousing] a
join [dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID and a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [dbo].[NashvilleHousing] a
join [dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID and a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------

--Breaking PropertyAddress into individual columns (address,city,state)

select * from [dbo].[NashvilleHousing]

Select Substring(PropertyAddress,1,Charindex(',',PropertyAddress)-1) as Address,
Substring(PropertyAddress,Charindex(',',PropertyAddress)+1,Len(PropertyAddress)) as City
From [dbo].[NashvilleHousing]

Alter Table NashvilleHousing
add PropertySplitAddress nvarchar(255)

Alter Table NashvilleHousing
add PropertySplitCity nvarchar(255)

Update NashvilleHousing
set PropertySplitAddress = Substring(PropertyAddress,1,Charindex(',',PropertyAddress)-1)

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress,Charindex(',',PropertyAddress)+1,Len(PropertyAddress))


--Use another simplier way to deliminate a string

Select OwnerAddress From [dbo].[NashvilleHousing]


Select PARSENAME(Replace(OwnerAddress,',','.'),1) as OwnerSplieState,
       PARSENAME(Replace(OwnerAddress,',','.'),2) as OwnerSplieCity,
	   PARSENAME(Replace(OwnerAddress,',','.'),3) as OwnerSplieAddress
From [dbo].[NashvilleHousing] 

Alter Table NashvilleHousing
Add OwnerSplieAddress nvarchar(255)

Alter Table NashvilleHousing
Add OwnerSplieCity nvarchar(255)

Alter Table NashvilleHousing
Add OwnerSplieState nvarchar(255)

Update NashvilleHousing
set OwnerSplieAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Update NashvilleHousing
set OwnerSplieCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Update NashvilleHousing
set OwnerSplieState = PARSENAME(Replace(OwnerAddress,',','.'),1)


------------------------------------------------------------------------------------------------------------------

--Change Y and N to 'Yes' and 'NO' in SoldAsVacant field

Select Distinct(SoldAsVacant),count(SoldAsVacant)
from [dbo].[NashvilleHousing]
group by SoldAsVacant
order by 2


Select SoldAsVacant,
  case When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
From [dbo].[NashvilleHousing]

Update NashvilleHousing
Set SoldAsVacant = case When SoldAsVacant = 'Y' then 'Yes'
	                    When SoldAsVacant = 'N' then 'No'
	                    else SoldAsVacant
						end

--------------------------------------------------------------------------------------------------------------

--Remove Duplicates

select * from [dbo].[NashvilleHousing]

--Using CTE and ROW_NUMBER() to find out duplicate rows

With RowNumCTE as
(Select *, 
ROW_NUMBER() over (Partition by ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference
                 Order by UniqueID) Row_Number
From [dbo].[NashvilleHousing]
)
Select *
From RowNumCTE
where ROW_NUMBER>1

--Then delete those duplicate rows

With RowNumCTE as
(Select *, 
ROW_NUMBER() over (Partition by ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference
                 Order by UniqueID) Row_Number
From [dbo].[NashvilleHousing]
)
Delete 
From RowNumCTE
where ROW_NUMBER>1

-------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

select * from [dbo].[NashvilleHousing]

Alter Table [dbo].[NashvilleHousing]
Drop Column PropertyAddress,OwnerAddress

Alter Table [dbo].[NashvilleHousing]
Drop Column SaleDate
