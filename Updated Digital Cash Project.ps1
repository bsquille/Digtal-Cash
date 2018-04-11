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

#Secret Splitting of Hardcoded numbers from above.
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

#Blinding the Money Orders

#Using Perl script to calculate large numbers for modulo equations 
$K1 > PerlInput.txt
$e >> PerlInput.txt
$n >> PerlInput.txt
perl LargeNumberCalc.pl

#Blinding Money Order 1
[int]$BlFa = Get-Content -path PerlOutput.txt
[int]$US1 = 1
[int32[]]$MO1 = $Amount, $US1 + $I11 + $I12
$temp = $MO1
echo $temp > Output/MoneyOrder1.txt
write-host "`nMO1: `nAmount = $($MO1[0]) `nUniqueness String = $($MO1[1]) `nI11 = $($MO1[2..5]) `nI12 = $($MO1[6..9])"
new-item temp.txt -ItemType file
For($i=0; $i -lt $MO1.length; $i++) {
	(($MO1[$i] * $BlFa) % $n) >> temp.txt
}
[int32[]]$BMO1 = Get-Content -path temp.txt
echo "`nBlinded first money order"
$temp = $BMO1
echo $temp > Output/BlindedMoneyOrder1.txt
write-host "Blinded MO1: `nAmount = $($BMO1[0]) `nUniqueness String = $($BMO1[1]) `nI11 = $($BMO1[2..5]) `nI12 = $($BMO1[6..9])"
Remove-Item temp.txt


#Using Perl script to calculate large numbers for modulo equations
$K2 > PerlInput.txt
$e >> PerlInput.txt
$n >> PerlInput.txt
perl LargeNumberCalc.pl
#Blinding Money Order 2
[int]$BlFa = Get-Content -path PerlOutput.txt
[int]$US2 = 2
[int32[]]$MO2 = $Amount, $US1 + $I21 + $I22
$temp = $MO2
echo $temp > Output/MoneyOrder2.txt
write-host "`nMO2: `nAmount = $($MO2[0]) `nUniqueness String = $($MO2[1]) `nI21 = $($MO2[2..5]) `nI22 = $($MO2[6..9])"
new-item temp.txt -ItemType file
For($i=0; $i -lt $MO2.length; $i++) {
	(($MO2[$i] * $BlFa) % $n) >> temp.txt
}
[int32[]]$BMO2 = Get-Content -path temp.txt
echo "`nBlinded second money order"
$temp = $BMO2
echo $temp > Output/BlindedMoneyOrder2.txt
write-host "`nBlinded MO2: `nAmount = $($BMO2[0]) `nUniqueness String = $($BMO2[1]) `nI21 = $($BMO2[2..5]) `nI22 = $($BMO2[6..9])"
Remove-Item temp.txt

echo "`n##Blinding Money Orders Complete##"





#Unblinding the Money Orders
echo "'nBank enters which Money Order to unblind"
$Rand = Read-Host
#$Rand = 2

if ($Rand -eq 1) {

$K1 > PerlInput.txt
$Inverse >> PerlInput.txt
$n >> PerlInput.txt
perl LargeNumberCalc.pl
[int]$InvK1 = Get-Content -path PerlOutput.txt 
$InvK1 > PerlInput.txt
$e >> PerlInput.txt
$n >> PerlInput.txt
perl LargeNumberCalc.pl
$BlFa = Get-Content -path PerlOutput.txt
new-item temp.txt -ItemType file
For($i=0; $i -lt $BMO1.length; $i++) {
	(($BMO1[$i] * $BlFa) % $n) >> temp.txt
}
[int32[]]$BMO1 = Get-Content -path temp.txt
echo "`nUnblinded Money Order One"
$temp = $BMO1
echo $temp > Output/UnBlindedMoneyOrder1.txt
write-host "Un-Blinded MO1: `nAmount = $($BMO1[0]) `nUniqueness String = $($BMO1[1]) `nI11 = $($BMO1[2..5]) `nI12 = $($BMO1[6..9])"
Remove-Item temp.txt
echo "You provide: `n(R11, R111, R112) = ($R11, $R111, $R112) `n(S11, S111, S112) = ($S11, $S111, $S112) `n(R12, R121, R122) = ($R12, $R121, $R122) `n(S12, S121, S122) = ($S12, $S121, $S122)"
echo "`nBank calculates and verifies"
[int]$temp = $R11 -bxor $R111 -bxor $R112
echo "$($I11[0..1]) = [$temp, $($I11[1])]"
[int]$temp = $S11 -bxor $S111 -bxor $S112
echo "$($I11[2..3]) = [$temp, $($I11[3])]"
[int]$temp = $R12 -bxor $R121 -bxor $R122
echo "$($I12[0..1]) = [$temp, $($I12[1])]"
[int]$temp = $S12 -bxor $S121 -bxor $S122
echo "$($I12[2..3]) = [$temp, $($I12[3])]"

echo "`nCombine ID:"
[int]$temp = $R11 -bxor $S11
echo "[$R11 xor $S11] = $temp (Your ID)"
[int]$temp = $R12 -bxor $S12
echo "[$R12 xor $S12] = $temp (Your ID)"

echo "`nBank signs blinded Money Order two"
new-item temp.txt -ItemType file
For($i=0; $i -lt $BMO2.length; $i++) {
	$($BMO2[$i]) > PerlInput.txt
	$d >> PerlInput.txt
	$n >> PerlInput.txt
	perl LargeNumberCalc.pl
	[int]$temp = Get-Content -path PerlOutput.txt
	$temp >> temp.txt
}
[int32[]]$Signature = Get-Content -path temp.txt
Remove-Item temp.txt
echo "`nThe Signature is $Signature"
[int32[]]$BMO2Sig = $($BMO2) + $Signature
[int32[]]$temp = $($BMO2Sig)
echo $temp > Output/BlindedSignedMoneyOrder2.txt
echo "`nBlinded Signed Money Order Two: `nAmount = $($BMO2Sig[0]) `nUniqueness String = $($BMO2Sig[1]) `nI21 = $($BMO2Sig[2..5]) `nI22 = $($BMO2Sig[6..9]) `nSignature: ($($BMO2Sig[10..19]))"

echo "`nYou unblind the signed money order"
$K2 > PerlInput.txt
$Inverse >> PerlInput.txt
$n >> PerlInput.txt
perl LargeNumberCalc.pl
[int]$InvK2 = Get-Content -path PerlOutput.txt 
$InvK2 > PerlInput.txt
$e >> PerlInput.txt
$n >> PerlInput.txt
perl LargeNumberCalc.pl
$BlFa = Get-Content -path PerlOutput.txt
new-item temp.txt -ItemType file
For($i=0; $i -lt 10; $i++) {
	(($BMO2Sig[$i] * $BlFa) % $n) >> temp.txt
}
[int32[]]$MO2Sig1 = Get-Content -path temp.txt
Remove-Item temp.txt
new-item temp.txt -ItemType file
For($i=10; $i -lt 20; $i++) {
	(($BMO2Sig[$i] * $InvK2) % $n) >> temp.txt
}
[int32[]]$MO2Sig2 = Get-Content -path temp.txt
[int32[]]$MO2Sig = $($MO2Sig1) + $($MO2Sig2)
[int32[]]$temp = $($MO2Sig)
echo $temp > Output/UnBlindedSignedMoneyOrder2.txt
write-host "`nUn-Blinded MO2: `nAmount = $($MO2Sig[0]) `nUniqueness String = $($MO2Sig[1]) `nI11 = $($MO2Sig[2..5]) `nI12 = $($MO2Sig[6..9])"
write-host "Un-Blinded Signature: `n($($MO2Sig[10..19]))"
Remove-Item temp.txt

echo "`nYou would like to use the unblinded signed money order with a Merchant. `nThe Merchant verifies the signature."
new-item temp.txt -ItemType file
For($i=10; $i -lt 20; $i++) {
	$($MO2Sig[$i]) > PerlInput.txt
	$e >> PerlInput.txt
	$n >> PerlInput.txt
	perl LargeNumberCalc.pl
	[int]$temp = Get-Content -path PerlOutput.txt
	$temp >> temp.txt
}
[int32[]]$TestSig = Get-Content -path temp.txt
Remove-Item temp.txt

For($i=0; $i -lt 10; $i++) {
	write-host "$($MO2Sig[$i]) = $($TestSig[$i])"
}
echo "If the money order values (left) == the calculated signature values (right), the signature is valid."

echo "`nYou reveal halves"
#[int]$NBit1 = Get-Random -minimum 0 -maximum 1
[int]$NBit1 = 0
#[int]$NBit2 = Get-Random -minimum 0 -maximum 1
[int]$NBit2 = 1

if ($Nbit1 -eq 0) {
	echo "`nYou Provide ($R21, $R211, $R212)"
	[int]$temp = ($R21 -bxor $R211 -bxor $R212)
	write-host "Merchant verifies $temp, $R211 = $I21L"
	[int32[]]$NewIDS1 = $I21R + $R21
	echo "Reveal I21L = $R21"
	}
elseif ($Nbit1 -eq 1) {
	echo "`nYou Provide ($S21, $S211, $S212)"
	[int]$temp = ($S21 -bxor $S211 -bxor $S212)
	write-host "Merchant verifies $temp, $S211 = $I21R"
	[int32[]]$NewIDS1 = $I21L + $S21
	echo "Reveal I21R = $S21"
	}
else { echo "An error occurred" }

if ($Nbit2 -eq 0) {
	echo "`nYou Provide ($R22, $R221, $R222)"
	[int]$temp = ($R22 -bxor $R221 -bxor $R222)
	write-host "Merchant verifies $temp, $R221 = $I22L"
	[int32[]]$NewIDS2 = $I22R + $R22
	echo "Reveal I22L = $R22"
	}
elseif ($Nbit2 -eq 1) {
	echo "`nYou Provide ($S22, $S221, $S222)"
	[int]$temp = ($S22 -bxor $S221 -bxor $S222)
	write-host "Merchant verifies $temp, $S221 = $I22R"
	[int32[]]$NewIDS2 = $I22L + $S22
	echo "Reveal I22R = $S22"
	}
else { echo "An error occurred" }

echo "`nMerchant submits opened money order to the bank `n "
[int32[]]$temp = $Amount 
$temp += $US1
$temp += $($NewIDS1)
$temp += $($NewIDS2)
echo $temp > Output/OpenedMoneyOrderForBank.txt
write-host "`nAmount = $Amount `nUniqueness String = $US1 `nI21 = $($NewIDS1) `nI22 = $($NewIDS2)"

}
elseif ($Rand -eq 2) {
$K2 > PerlInput.txt
$Inverse >> PerlInput.txt
$n >> PerlInput.txt
perl LargeNumberCalc.pl

[int]$InvK2 = Get-Content -path PerlOutput.txt 
$InvK2 > PerlInput.txt
$e >> PerlInput.txt
$n >> PerlInput.txt
perl LargeNumberCalc.pl

$BlFa = Get-Content -path PerlOutput.txt
new-item temp.txt -ItemType file
For($i=0; $i -lt $BMO2.length; $i++) {
	(($BMO2[$i] * $BlFa) % $n) >> temp.txt
}
[int32[]]$BMO2 = Get-Content -path temp.txt
echo "`nUnblinded Money Order Two"
$temp = $BMO2
echo "$temp" > Output/UnBlindedMoneyOrder2.txt
write-host "`nUn-Blinded MO2: `nAmount = $($BMO2[0]) `nUniqueness String = $($BMO2[1]) `nI21 = $($BMO2[2..5]) `nI22 = $($BMO2[6..9])"
Remove-Item temp.txt
echo "`nYou provide: `n(R21, R211, R212) = ($R21, $R211, $R212) `n(S21, S211, S212) = ($S21, $S211, $S212) `n(R22, R221, R222) = ($R22, $R221, $R222) `n(S22, S221, S222) = ($S22, $S221, $S222)"
echo "`nBank calculates and verifies"
[int]$temp = $R21 -bxor $R211 -bxor $R212
echo "$($I21[0..1]) = [$temp, $($I21[1])]"
[int]$temp = $S21 -bxor $S211 -bxor $S212
echo "$($I21[2..3]) = [$temp, $($I21[3])]"
[int]$temp = $R22 -bxor $R221 -bxor $R222
echo "$($I22[0..1]) = [$temp, $($I22[1])]"
[int]$temp = $S22 -bxor $S221 -bxor $S222
echo "$($I22[2..3]) = [$temp, $($I22[3])]"

echo "`nCombine ID:"
[int]$temp = $R21 -bxor $S21
echo "[$R21 xor $S21] = $temp (Your ID)"
[int]$temp = $R22 -bxor $S22
echo "[$R22 xor $S22] = $temp (Your ID)"

echo "`nBank signs blinded Money Order one"
new-item temp.txt -ItemType file
For($i=0; $i -lt $BMO1.length; $i++) {
	$($BMO1[$i]) > PerlInput.txt
	$d >> PerlInput.txt
	$n >> PerlInput.txt
	perl LargeNumberCalc.pl
	[int]$temp = Get-Content -path PerlOutput.txt
	$temp >> temp.txt
}
[int32[]]$Signature = Get-Content -path temp.txt
Remove-Item temp.txt
echo "`nThe Signature is $Signature"
[int32[]]$BMO1Sig = $BMO1 + $Signature
[int32[]]$temp = $($BMO1Sig)
echo $temp > Output/BlindedSignedMoneyOrder1.txt
echo "`nBlinded Signed Money Order One: `nAmount = $($BMO1Sig[0]) `nUniqueness String = $($BMO1Sig[1]) `nI11 = $($BMO1Sig[2..5]) `nI12 = $($BMO1Sig[6..9]) `nSignature: ($($BMO1Sig[10..19]))"

echo "`nYou unblind the signed money order"
$K1 > PerlInput.txt
$Inverse >> PerlInput.txt
$n >> PerlInput.txt
perl LargeNumberCalc.pl
[int]$InvK1 = Get-Content -path PerlOutput.txt 
$InvK1 > PerlInput.txt
$e >> PerlInput.txt
$n >> PerlInput.txt
perl LargeNumberCalc.pl
$BlFa = Get-Content -path PerlOutput.txt
new-item temp.txt -ItemType file
For($i=0; $i -lt 10; $i++) {
	(($BMO1Sig[$i] * $BlFa) % $n) >> temp.txt
}
[int32[]]$MO1Sig1 = Get-Content -path temp.txt
Remove-Item temp.txt
new-item temp.txt -ItemType file
For($i=10; $i -lt 20; $i++) {
	(($BMO1Sig[$i] * $InvK1) % $n) >> temp.txt
}
[int32[]]$MO1Sig2 = Get-Content -path temp.txt
[int32[]]$MO1Sig = $MO1Sig1 + $MO1Sig2
[int32[]]$temp = $($MO1Sig)
echo $temp > Output/UnBlindedSignedMoneyOrder1.txt
write-host "`nUn-Blinded MO1: `nAmount = $($MO1Sig[0]) `nUniqueness String = $($MO1Sig[1]) `nI11 = $($MO1Sig[2..5]) `nI12 = $($MO1Sig[6..9])"
write-host "Un-Blinded Signature: `n($($MO1Sig[10..19]))"
Remove-Item temp.txt

echo "`nYou would like to use the unblinded signed money order with a Merchant. `nThe Merchant verifies the signature."
new-item temp.txt -ItemType file
For($i=10; $i -lt 20; $i++) {
	$($MO1Sig[$i]) > PerlInput.txt
	$e >> PerlInput.txt
	$n >> PerlInput.txt
	perl LargeNumberCalc.pl
	[int]$temp = Get-Content -path PerlOutput.txt
	$temp >> temp.txt
}
[int32[]]$TestSig = Get-Content -path temp.txt
Remove-Item temp.txt

For($i=0; $i -lt 10; $i++) {
	write-host "$($MO1Sig[$i]) = $($TestSig[$i])"
}
echo "`nIf the money order values (left) == the calculated signature values (right), the signature is valid."

echo "`nYou reveal halves"
#[int]$NBit1 = Get-Random -minimum 0 -maximum 1
[int]$NBit1 = 0
#[int]$NBit2 = Get-Random -minimum 0 -maximum 1
[int]$NBit2 = 1

if ($Nbit1 -eq 0) {
	echo "`nYou Provide ($R11, $R111, $R112)"
	[int]$temp = ($R11 -bxor $R111 -bxor $R112)
	write-host "Merchant verifies $temp, $R111 = $I11L"
	[int32[]]$NewIDS1 = $I11R + $R11
	echo "Reveal I11L = $R11"
	}
elseif ($Nbit1 -eq 1) {
	echo "`nYou Provide ($S11, $S111, $S112)"
	[int]$temp = ($S11 -bxor $S111 -bxor $S112)
	write-host "Merchant verifies $temp, $S111 = $I11R"
	[int32[]]$NewIDS1 = $I11L + $S11
	echo "Reveal I11R = $S11"
	}
else { echo "An error occurred" }

if ($Nbit2 -eq 0) {
	echo "`nYou Provide ($R12, $R121, $R122)"
	[int]$temp = ($R12 -bxor $R121 -bxor $R122)
	write-host "Merchant verifies $temp, $R121 = $I12L"
	[int32[]]$NewIDS2 = $I12R + $R12
	echo "Reveal I12L = $R12"
	}
elseif ($Nbit2 -eq 1) {
	echo "`nYou Provide ($S12, $S121, $S122)"
	[int]$temp = ($S12 -bxor $S121 -bxor $S122)
	write-host "Merchant verifies $temp, $S121 = $I12R"
	[int32[]]$NewIDS2 = $I12L + $S12
	echo "Reveal I12R = $S12"
	}
else { echo "An error occurred" }

echo "`nMerchant submits opened money order to the bank `n "
[int32[]]$temp = $Amount 
$temp += $US2
$temp += $($NewIDS1)
$temp += $($NewIDS2)
echo $temp > Output/OpenedMoneyOrderForBank.txt
write-host "`nAmount = $Amount `nUniqueness String = $US2 `nI11 = $($NewIDS1) `nI12 = $($NewIDS2)"

}
else { echo "An Error Occurred" }

pause