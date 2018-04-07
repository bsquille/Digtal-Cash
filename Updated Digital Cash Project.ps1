#Constants
[int]$e = 29
[int]$n = 571
[int]$d = 59
[int]$Amount = 100
[int]$ID = 8
[int]$Inverse = -1

#Random Numbers
[int]$R11 = 61
[int]$R12 = 80
[int]$R21 = 76
[int]$R22 = 22
[int]$R111 = 64
[int]$R112 = 50
[int]$S111 = 97
[int]$S112 = 89
[int]$R121 = 76
[int]$R122 = 86
[int]$S121 = 44
[int]$S122 = 82
[int]$R211 = 42
[int]$R212 = 34
[int]$S211 = 30
[int]$S212 = 26
[int]$R221 = 23
[int]$R222 = 45
[int]$S221 = 93
[int]$S222 = 34
[int]$K1 = 87
[int]$K2 = 28

#Secret Splitting
[int]$S11 = $R11 -bxor $ID
[int]$S12 = $R12 -bxor $ID
[int]$S21 = $R21 -bxor $ID
[int]$S22 = $R22 -bxor $ID

echo "##Secret Splitting Complete $S11 $S12 $S21 $S22##"

#Bit commitment
[int32[]]$I11L = ($R11 -bxor $R111 -bxor $R112), $R111
[int32[]]$I11R = ($S11 -bxor $S111 -bxor $S112), $S111
[int32[]]$I12L = ($R12 -bxor $R121 -bxor $R122), $R121
[int32[]]$I12R = ($S12 -bxor $S121 -bxor $S122), $S121
[int32[]]$I21L = ($R21 -bxor $R211 -bxor $R212), $R211
[int32[]]$I21R = ($S21 -bxor $S211 -bxor $S212), $S211
[int32[]]$I22L = ($R22 -bxor $R221 -bxor $R222), $R221
[int32[]]$I22R = ($S22 -bxor $S221 -bxor $S222), $S221

[int32[]]$I11 = $I11L + $I11R
[int32[]]$I12 = $I12L + $I12R
[int32[]]$I21 = $I21L + $I21R
[int32[]]$I22 = $I22L + $I22R

echo "`n##Bit Commitment Complete##"
echo "$I11L"
echo "$I11R"
echo "$I12L"
echo "$I12R"
echo "$I21L"
echo "$I21R"
echo "$I22L"
echo "$I22R"

#Blind the MOs
$K1 > PerlInput.txt
$e >> PerlInput.txt
$n >> PerlInput.txt
perl LargeNumberCalc.pl
echo "`nPausing for Perl to calculate"
pause
[int]$BlFa = Get-Content -path PerlOutput.txt
#echo "$BlFa" 
[int]$US1 = 1
[int32[]]$MO1 = $Amount, $US1 + $I11 + $I12
#echo "MO1 equals $MO1"
new-item temp.txt -ItemType file
For($i=0; $i -lt $MO1.length; $i++) {
	(($MO1[$i] * $BlFa) % $n) >> temp.txt
}
[int32[]]$BMO1 = Get-Content -path temp.txt
echo "`nBlinded first money order $BMO1"
Remove-Item temp.txt

$K2 > PerlInput.txt
$e >> PerlInput.txt
$n >> PerlInput.txt
perl LargeNumberCalc.pl
echo "`nPausing for Perl to calculate"
pause
[int]$BlFa = Get-Content -path PerlOutput.txt
[int]$US2 = 2
[int32[]]$MO2 = $Amount, $US2 + $I21 + $I22
#echo "MO2 equals $MO2"
new-item temp.txt -ItemType file
For($i=0; $i -lt $MO2.length; $i++) {
	(($MO2[$i] * $BlFa) % $n) >> temp.txt
}
[int32[]]$BMO2 = Get-Content -path temp.txt
echo "`nBlinded second money order $BMO2"
Remove-Item temp.txt

echo "`n##Blinding Money Orders Complete##"

#Unblind Money Order
#$Rand = Get-Random -minimum 1 -maximum 2
$Rand = 2

if ($Rand -eq 1) {

$K1 > PerlInput.txt
$Inverse >> PerlInput.txt
$n >> PerlInput.txt
perl LargeNumberCalc.pl
echo "`nPausing for Perl to calculate"
pause
[int]$InvK1 = Get-Content -path PerlOutput.txt 
$InvK1 > PerlInput.txt
$e >> PerlInput.txt
$n >> PerlInput.txt
perl LargeNumberCalc.pl
echo "`nPausing for Perl to calculate"
pause
$BlFa = Get-Content -path PerlOutput.txt
new-item temp.txt -ItemType file
For($i=0; $i -lt $BMO1.length; $i++) {
	(($BMO1[$i] * $BlFa) % $n) >> temp.txt
}
[int32[]]$BMO1 = Get-Content -path temp.txt
echo "`nUnblinded Money Order 1 $BMO1"
Remove-Item temp.txt

}
elseif ($Rand -eq 2) {
$K2 > PerlInput.txt
$Inverse >> PerlInput.txt
$n >> PerlInput.txt
perl LargeNumberCalc.pl
echo "`nPausing for Perl to calculate"
pause
[int]$InvK2 = Get-Content -path PerlOutput.txt 
$InvK2 > PerlInput.txt
$e >> PerlInput.txt
$n >> PerlInput.txt
perl LargeNumberCalc.pl
echo "`nPausing for Perl to calculate"
pause
$BlFa = Get-Content -path PerlOutput.txt
new-item temp.txt -ItemType file
For($i=0; $i -lt $BMO2.length; $i++) {
	(($BMO2[$i] * $BlFa) % $n) >> temp.txt
}
[int32[]]$BMO2 = Get-Content -path temp.txt
echo "`nUnblinded Money Order 2 $BMO2"
Remove-Item temp.txt

}
else { echo "An Error Occurred" }

pause
