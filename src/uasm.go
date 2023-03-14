package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
	"regexp"
	"sort"
	"strings"
)

type elements struct{
	labels, nemonics map[string]int
	lbl_rev map[int]string
}

func exists( k string, m map[string]int ) bool {
	_, b := m[k]
	return b
}

func get_nemonics( f io.Reader ) ( all elements, assign string ) {
	scanner := bufio.NewScanner(f)
	scanner.Split(bufio.ScanLines)
	re_label:= regexp.MustCompile("^[A-Z0-9]*:")
	found := make(map[string]bool)
	lbl_cnt := 0
	all.labels = make(map[string]int)
	all.lbl_rev = make(map[int]string)

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line=="" || line[0] == '#' {
			continue
		}
		if re_label.MatchString(line) {
			halves := strings.Split(line,":")
			lbl_name := halves[0]
			if exists(lbl_name,all.labels) {
				log.Fatal("Duplicated label ", lbl_name)
			}
			all.labels[lbl_name] = lbl_cnt
			all.lbl_rev[lbl_cnt] = lbl_name
			lbl_cnt++
			for _,each := range strings.Split(halves[1],",") {
				each = strings.TrimSpace(each)
				if each=="" {
					continue
				}
				found[each]=true
			}
		}
	}
	all_nem := make([]string,0)
	for k,_ := range found {
		all_nem = append(all_nem,k)
	}
	sort.Slice(all_nem,func(i,j int) bool {return all_nem[i]<all_nem[j]})
	assign = make_assign( all_nem )
	sorted := make(map[string]int)
	for k,_ := range all_nem {
		sorted[all_nem[k]] = k
	}
	all.nemonics = sorted
	return all, assign
}

func asm( f io.Reader, all elements ) (rom []int64) {
	linecnt := 0
	scanner := bufio.NewScanner(f)
	scanner.Split(bufio.ScanLines)
	re_label:= regexp.MustCompile("^[A-Z0-9]*:")
	rom = make([]int64,64*16)
	cur_cat := 0
	subidx := 0

	for scanner.Scan() {
		linecnt++
		line := strings.TrimSpace(scanner.Text())
		if line=="" || line[0] == '#' {
			continue
		}
		if re_label.MatchString(line) {
			halves := strings.Split(line,":")
			cur_cat = all.labels[halves[0]]
			subidx  = 0
			line = halves[1]
		} else {
			subidx++
			if subidx>15 {
				log.Fatal("Subroutine overflow at line ",linecnt)
			}
		}
		val := int64(0)
		for _,each := range strings.Split(line,",") {
			each = strings.TrimSpace(each)
			if each == "" {
				continue
			}
			val |= int64(1) << all.nemonics[each]
		}
		addr := (cur_cat<<4)|subidx
		if val != 0 {
			fmt.Printf("%2X - %X\n",addr,val)
		}
		rom[ addr ] = val
	}
	return rom
}


func tr( s string ) string {
	x := strings.ToLower(s)
	if strings.Index(x,"=")>-1 {
		halves:=strings.Split(x,"=")
		if halves[1]=="0" {
			return "clr_" + halves[0]
		}
		if halves[1]=="1" {
			return "set_" + halves[0]
		}
		return "set_" + halves[0] + "_" + halves[1]
	}
	return x
}

func make_assign( all []string ) (s string ) {
	s += fmt.Sprintf("assign { ")
	first := true
	k2 := 0
	for k:=len(all)-1;k>=0;k--{
		if !first {
			s += fmt.Sprintf(", ")
		}
		if k>0 && ((k+1)%1==0) {
			s += fmt.Sprintf("\n        ")
		}
		s += fmt.Sprintf( "%s", tr(all[k]) )
		first=false
		k2++
	}
	s += fmt.Sprintf( "\n        } = ucode;\n")
	return s
}

func dump_inc( a ...string) {
	path := "../hdl"
	f, err := os.Create( path + "/jtkcpu_ucode.inc")
	if err != nil {
		log.Fatal("Cannot open " + path)
	}
	defer f.Close()
	for _,each:=range(a) {
		fmt.Fprintln(f,each)
	}
}

func make_case( rom []int64, all elements ) (s string) {
	nem_len := len(all.nemonics)
	i := "    "
	s += fmt.Sprintf("always @* begin\n%scase( addr )\n",i)
	for k, each := range rom {
		if each!=0 {
			s += fmt.Sprintf("%s%s%03X: ucode = %d'h%03X;", i,i, k, nem_len, each )
			opcat := k>>4
			if all.lbl_rev[opcat] != "" && (k&0xf)==0 {
				s += fmt.Sprintf("    // %s", all.lbl_rev[opcat])
			}
			s += fmt.Sprintf("\n")
		}
	}
	s += fmt.Sprintf("%s%sdefault: ucode = 0;\n%sendcase\nend\n",i,i,i)
	return s
}

func main() {
	path := "../hdl/ucode"
	f, err := os.Open(path)
	if err != nil {
		log.Fatal("Cannot open " + path)
	}
	all, assign := get_nemonics(f)
	f.Close()
	// Generate ROM
	f, _ = os.Open(path)
	defer f.Close()
	rom := asm( f, all )
	rom_case := make_case(rom, all )
	dump_inc( assign, rom_case )
}