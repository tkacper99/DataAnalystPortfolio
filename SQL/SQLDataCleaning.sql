-- Wyœwietlanie typu danych oraz tabeli
SELECT *
FROM CovidPortfolio..Nashville

SELECT * FROM information_schema.columns WHERE Table_Name = 'Nashville'

-- Zmiana typu oraz formatu w zapisie daty
UPDATE CovidPortfolio..Nashville
SET SaleDate = TRY_CONVERT(DATE, SaleDate, 107);

ALTER TABLE CovidPortfolio..Nashville
ALTER COLUMN SaleDate DATE;

-- Uzupe³nianie brakuj¹ch pól adresowych na podstawie posiadanych informacje z innych zamówieñ
UPDATE FirstOne
SET PropertyAddress = ISNULL(FirstOne.PropertyAddress, SecondOne.PropertyAddress)
FROM CovidPortfolio..Nashville AS FirstOne
JOIN CovidPortfolio..Nashville AS SecondOne
	ON FirstOne.ParcelID = SecondOne.ParcelID
	AND FirstOne.UniqueID <> SecondOne.UniqueID
WHERE FirstOne.PropertyAddress IS NULL

-- Rozbijanie adresu na osobne kolumny zbieraj¹ce dane o mieœcie, ulicy oraz stanie
ALTER TABLE CovidPortfolio..Nashville
ADD PropertySplitAddress varchar(255);

UPDATE CovidPortfolio..Nashville
SET PropertySplitAddress = 
    CASE 
        WHEN CHARINDEX(',', PropertyAddress) > 0 THEN
            SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
        ELSE
            PropertyAddress
    END;

ALTER TABLE CovidPortfolio..Nashville
ADD PropertySplitCity varchar(255);

UPDATE CovidPortfolio..Nashville
SET PropertySplitCity = 
    CASE 
        WHEN CHARINDEX(',', PropertyAddress) > 0 THEN
            SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
        ELSE
            NULL
    END;

SELECT OwnerAddress
FROM CovidPortfolio..Nashville

-- SoldAsVacant standaryzacja danych
UPDATE CovidPortfolio..Nashville
SET SoldAsVacant =
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

-- Usuwanie duplikatów z tabeli
WITH RowNumberCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) row_num
FROM CovidPortfolio..Nashville
)
DELETE
FROM RowNumberCTE
WHERE row_num > 1