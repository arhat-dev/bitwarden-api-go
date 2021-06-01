package main

import (
	"io/ioutil"
	"os"
	"regexp"
)

func main() {
	exp := regexp.MustCompile(`(([a-zA-Z]+) ){2}= +([0-9]+)`)
	for _, file := range []string{
		"./bwinternal/openapi.go",
		"./bwpublic/openapi.go",
	} {
		var result []byte

		data, err := ioutil.ReadFile(file)
		if err != nil {
			panic(err)
		}

		println(len(exp.FindAllIndex(data, len(data)+1)))

		lastIdxInData := 0
		for _, loc := range exp.FindAllIndex(data, len(data)+1) {
			result = append(result, data[lastIdxInData:loc[0]]...)
			lastIdxInData = loc[1]

			match := data[loc[0]:loc[1]]
			subMatch := exp.FindSubmatch(match)
			if subMatch == nil {
				continue
			}

			nameAndType := subMatch[2]
			value := subMatch[3]

			result = append(result, nameAndType...)
			result = append(result, value...)
			result = append(result, []byte("_ ")...)
			result = append(result, nameAndType...)
			result = append(result, []byte(" = ")...)
			result = append(result, value...)
		}
		result = append(result, data[lastIdxInData:]...)

		err = os.WriteFile(file, result, 0640)
		if err != nil {
			panic(err)
		}
	}
}
