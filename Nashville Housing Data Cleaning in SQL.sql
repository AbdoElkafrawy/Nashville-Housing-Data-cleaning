
---DATA Cleaning Project 
select*
from NashvilleHousing

--- standrize saledate to remove the Timestamp 

select SaleDateconverted, convert (date,saledate)
from NashvilleHousing

alter table NashvilleHousing
add saleDateconverted date;


Update NashvilleHousing
SET SaleDateconverted = convert (date,saledate)

---populate Null Property address data, so we found that there are properties that has a parcelID and address 
--but some properties with that has same parcelID doesn't have an address, so we will Join the table on itself
--then Join it on the fact that the parcelID is equal in each but also the UniqueID is different in each

select *
from NashvilleHousing
--where PropertyAddress is null 
order by ParcelID

--- After finding out the Null values in property address , we can exchange the null values using the following statment 
--ISNULL(A.PropertyAddress, B.PropertyAddress) which means if the first part of the statment is Null replce it by the 2nd part value


select A.ParcelID, A.PropertyAddress, B.ParcelID,B.PropertyAddress ,ISNULL(A.PropertyAddress, B.PropertyAddress)
from NashvilleHousing A
join NashvilleHousing B
on a.ParcelID= B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

-- Now we Update our table by adding the new column we created . using the Update statment but we need to 
--Use the Alias instead of the tablename in the Update statment, also we have to use all the Join and from statment
--with the Update statment cause that's where we created the change

Update A 
set PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
from NashvilleHousing A
join NashvilleHousing B
on a.ParcelID= B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


---- Breaking the address into columns (1st line address, city), the goal is to get rid of the Cityname like "GOODLETTSVILLE"
-- FOR THAT we use the SUBSTRING STATMENT WHICHI is written like this
--SUBSTRING ("COLUMNNAME" we are want to query, 1 "means start looking from 1st value ,Charindex( 'specify the stop point in our case it's the COMMA cause it
-- in the same place in all column values seperating the city name from the rest of the address', columnname) -1 "the Minus 1 
-- tells it not to include the comma in the result so it only leaves us with the 1st line of the address)
--now we need to pull the city name on a seperate column as well, so we use the substring again 
--but it will be like substring (propertyaddress "columnname", charindex(',' ,propertyaddress"starting point") +1 "so it doesn't include the comma in the resul",
--Len (propertyaddress) "Len (X) tells it where to put that value after it seperates it )
select PropertyAddress
from NashvilleHousing
--where PropertyAddress is null 
--order by ParcelID

select 
SUBSTRING (propertyaddress ,1 ,CHARINDEX( ',',PropertyAddress) -1)  AS Address
,SUBSTRING ( propertyaddress ,CHARINDEX( ',',PropertyAddress) +1 ,len (propertyaddress))  AS Address
from NashvilleHousing
-- Now we need to Update our table to include the two new columns created (1st line address, city)

alter table NashvilleHousing
add propertysplitaddress nvarchar (255);


Update NashvilleHousing
SET propertysplitaddress = SUBSTRING (propertyaddress ,1 ,CHARINDEX( ',',PropertyAddress) -1) 

alter table NashvilleHousing
add propertysplitcity Nvarchar (255);


Update NashvilleHousing
SET propertysplitcity = SUBSTRING ( propertyaddress ,CHARINDEX( ',',PropertyAddress) +1 ,len (propertyaddress))

select *
from NashvilleHousing

---Now we want to do the same address split with the owner address, but instead of using substrings , we will use the parsname statment 
-- but the parsname statment looks for '.' not comma ',' so we will replace the comma by Dot, also it gives the result backwords so if 
-- when typing 1 as stating position ,it understands it to start from the back to front , usually it's written like this 
--PARSNAME( COLUMNNAME,1 "FOR THE POSITION WE WANT TO START FROM) but to include the replace statment in it we write it as 
-- parsname (replace (columnname , ',' , '.',),1) which means replace the comma by a fullstop in the columname specified

select 
PARSENAME (Replace (owneraddress, ',' , '.' ) ,3),
PARSENAME (Replace (owneraddress, ',' , '.' ) ,2),
PARSENAME (Replace (owneraddress, ',' , '.' ) ,1)
from NashvilleHousing

--now we need to add the new columns into the table using the alter then Update statments

alter table NashvilleHousing
add ownersplitaddress Nvarchar (255);


Update NashvilleHousing
SET ownersplitaddress = PARSENAME (Replace (owneraddress, ',' , '.' ) ,3)

alter table NashvilleHousing
add ownersplitcity Nvarchar (255);


Update NashvilleHousing
SET ownersplitcity = PARSENAME (Replace (owneraddress, ',' , '.' ) ,2)

alter table NashvilleHousing
add ownersplitstate Nvarchar (255);


Update NashvilleHousing
SET ownersplitstate = PARSENAME (Replace (owneraddress, ',' , '.' ) ,1)

select *
from NashvilleHousing

-----now we work on changing the Y & N to yes and No in the "soldAsVacant" column, 
--did the select distinct and counted soldasvacant first to know how many values appears as Y ,N,YES, NO .
--NOW WE WILL CHANGE THE Y,N TO YES ,NO using case statment

select distinct (soldasvacant),count (soldasvacant)
from NashvilleHousing
group by soldasvacant
order by 2

select SoldAsVacant ,
case 
when soldasvacant = 'Y' then 'YES'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
end 
from NashvilleHousing

-- now we Update the table using the Update statment 
 Update NashvilleHousing
 set SoldAsVacant= case 
when soldasvacant = 'Y' then 'YES'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
end 

------ Remove Duplicates using a CTE , so first we create the CTE THEN WE USE INSIDE IT THE PARTITION BY STATMENT 
--SO IT BRINGS ALL THE DUBLICATED VALUES WITHOUT ROLLING THEM UP 
--ROW_NUMBER function is a SQL ranking function that assigns a sequential rank number to each new record in a partition.
--When the SQL Server ROW NUMBER function detects two identical values in the same partition, it assigns different rank numbers to both.
--now that we know our dublicates ,to delete them we just replace Select by delete

WITH RowNnmCTE as
(
select* , ROW_NUMBER()
over (partition by parcelid, propertyaddress,saleprice,saledate,legalreference order by uniqueid ) row_num
from NashvilleHousing)

delete
from RowNnmCTE
where row_num> 1
--order by PropertyAddress

-------Delete unused columns , using the drop column statment 

select *
from NashvilleHousing

alter table NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress
alter table NashvilleHousing
drop column saledate
