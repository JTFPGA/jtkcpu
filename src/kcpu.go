package main

import(
    "encoding/xml"
    "fmt"
    "log"
    "io/ioutil"
)

type Machine struct {
	Name string `xml:"name,attr"`
	Src  string `xml:"sourcefile,attr"`
	Desc string `xml:"description"`
	Devices []struct {
		Name string `xml:"name,attr"`
	} `xml:"device_ref"`
}

type Mame struct {
	Machines []Machine `xml:"machine"`
}

func ShowGames() {
	buf, e := ioutil.ReadFile("mame.xml")
	if e!= nil {
		log.Fatal(e)
	}
	var mame Mame
	e = xml.Unmarshal( buf, &mame )
	if e!= nil {
		log.Fatal(e)
	}
	fmt.Printf("%-44s | %-14s | %s\n","Games","Setname","Source")
	fmt.Printf("---------------------------------------------|----------------|----------\n")
	for _,each := range mame.Machines {
		for _,dev := range each.Devices {
			if dev.Name=="konami_cpu" {
				fmt.Printf("%-44s | %-14s | %s\n",each.Desc,each.Name,each.Src[7:])
			}
		}
	}
}