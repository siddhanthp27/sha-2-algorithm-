#!/bin/bash

h0=1779033703
h1=3144134277
h2=1013904242
h3=2773480762
h4=1359893119
h5=2600822924
h6=528734635
h7=1541459225

touch temp
b=0
for i in `cat hashval2.txt`
do
	k[$b]=$i
	b=` expr $b + 1 `
done # storing array of round constants


len=$(cat test1 | wc -m)
n=$(bc <<< "$len/64")
((n++))
n=$((64 * $n))
x=$(($n - $len))
for ((i=0;i<$x;i++))
do
  echo -n "1" | cat >> test1
done
#cat test1

for i in `cat test1`
do
  for ((j=0;j<${#i};j++))
  do
    a=`echo -n ${i:$j:1} | xxd -b | cut -d" " -f2`
    a=`echo "ibase=2;$a" | bc`
    echo $a | cat >> temp
  done
done

b=0
for i in `cat temp`
do
  words[$b]=$i
  ((b++))
done

echo
#cat temp
len_temp=`cat temp | wc -l`
#echo $len_temp
#counter=$(bc <<< "$len_temp/16")
counter=$(echo "$len_temp/16" | bc)
#echo $counter
iter=0
for ((i=0;i<$counter;i++))
do
  for ((j=0;j<16;j++))
  do
    w[$j]=${words[$iter]}
    ((iter++))
  done

  k=16
  while((k < 64))
  do
      temp1=${w[$((k-15))]}

      tempp1=$((temp1 >> 7))
      tempp2=$((temp1 >> 18))
      tempp3=$((temp1 >> 3))

      s0=$((tempp1 ^ tempp2 ^ tempp3))

      temp2=${w[$((k-2))]}
      tempp4=$((temp2 >> 17))
      tempp5=$((temp2 >> 19))
      tempp6=$((temp2 >> 10))

      s1=$((tempp4 ^ tempp5 ^ tempp6))
      w[$k]=$((${w[$((k-16))]} + s0 + s1 + ${w[$((k-7))]}))

      k=$((k+1))
    done
    a=h0
    b=h1
    c=h2
    d=h3
    e=h4
    f=h5
    g=h6
    h=h7

    for ((l=0;l<64;l++))
    do
      temp1=$((e >> 6))
      temp2=$((e >> 11))
      temp3=$((e >> 25))
      S1=$((temp1 ^ temp2 ^ temp3))
      temp4=$((e & f))
      temp5=$((~e))
      temp6=$((temp5 & g))
      ch=$((temp4 ^ temp6))
      temporary1=$((h + S1 + ch + k[$l] + w[$l]))
      temp7=$((a >> 2))
      temp8=$((a >> 13))
      temp9=$((a >> 22))
      S0=$((temp7 ^ temp8 ^ temp9))
      temp10=$((a & b))
      temp11=$((a & c))
      temp12=$((b & c))
      maj=$((temp10 ^ temp11 ^ temp12))
      temporary2=$((S0 + maj))

      h=$g
      g=$f
      f=$e
      e=$((d + temporary1))
      d=$c
      c=$b
      b=$a
      a=$((temporary1 + temporary2))
    done

    h0=$((h0 + a))
    h1=$((h1 + b))
    h2=$((h2 + c))
    h3=$((h3 + d))
    h4=$((h4 + e))
    h5=$((h5 + f))
    h6=$((h6 + g))
    h7=$((h7 + h))
done

h0=`echo "obase=16; $h0" | bc`
h1=`echo "obase=16; $h1" | bc`
h2=`echo "obase=16; $h2" | bc`
h3=`echo "obase=16; $h3" | bc`
h4=`echo "obase=16; $h4" | bc`
h5=`echo "obase=16; $h5" | bc`
h6=`echo "obase=16; $h6" | bc`
h7=`echo "obase=16; $h7" | bc`

echo $h0$h1$h2$h3$h4$h5$h6$h7
rm temp
