package main

import (
	"bytes"
	"context"
	_ "embed" //nolint
	"fmt"
	"os"
	"path/filepath"
	"text/template"

	"github.com/google/go-github/v61/github"
)

const (
	org  = "regolith-linux"
	repo = "test-desktop-installable-action"
)

type distribution string

const (
	Debian distribution = "debian"
	Ubuntu distribution = "ubuntu"
)

var supportedDistros = []distribution{Debian, Ubuntu}

//go:embed tmpl/ci.tmpl
var tplCI []byte

//go:embed tmpl/test-old-repo.tmpl
var tplOldRepoTest []byte

//go:embed tmpl/test-new-repo.tmpl
var tplNewRepoTest []byte

//go:embed tmpl/test-migrate-repo.tmpl
var tplMigrateRepoTest []byte

func main() {
	distros, err := getDistros()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %s\n", err.Error())
		os.Exit(1)
	}

	if err := renderFiles(tplCI, "ci", distros); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %s\n", err.Error())
		os.Exit(1)
	}

	if err = renderFiles(tplOldRepoTest, "test-old-repo", distros); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %s\n", err.Error())
		os.Exit(1)
	}

	if err = renderFiles(tplNewRepoTest, "test-new-repo", distros); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %s\n", err.Error())
		os.Exit(1)
	}

	if err = renderFiles(tplMigrateRepoTest, "test-migrate-repo", distros); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %s\n", err.Error())
		os.Exit(1)
	}
}

type Distro struct {
	Name  string
	Codes []string
}

func getDistros() ([]Distro, error) {
	ctx := context.Background()
	client := github.NewClient(nil)

	dirs, err := getContents(ctx, client, "")
	if err != nil {
		return nil, err
	}

	distros := []Distro{}

	for _, d := range dirs {
		if d := checkDir(d); d == nil {
			continue
		}

		if !isDistroSupported(*d.Name) {
			continue
		}

		dist := Distro{
			Name: *d.Name,
		}

		subdirs, err := getContents(ctx, client, *d.Name)
		if err != nil {
			return nil, err
		}

		for _, s := range subdirs {
			if s := checkDir(s); s == nil {
				continue
			}

			dist.Codes = append(dist.Codes, *s.Name)
		}

		distros = append(distros, dist)
	}

	return distros, nil
}

func getContents(ctx context.Context, client *github.Client, path string) ([]*github.RepositoryContent, error) {
	opts := &github.RepositoryContentGetOptions{
		Ref: "main",
	}

	_, dirs, _, err := client.Repositories.GetContents(ctx, org, repo, path, opts)
	if err != nil {
		return nil, err
	}

	if dirs == nil {
		return nil, fmt.Errorf("error: something went wrong")
	}

	return dirs, nil
}

func checkDir(dir *github.RepositoryContent) *github.RepositoryContent {
	if dir.Name == nil {
		return nil
	}

	if dir.Type == nil {
		return nil
	}
	if *dir.Type != "dir" {
		return nil
	}

	return dir
}

func isDistroSupported(name string) bool {
	for _, d := range supportedDistros {
		if string(d) == name {
			return true
		}
	}
	return false
}

func renderFiles(tpl []byte, name string, distros []Distro) error {
	tmpl, err := template.New(name).Parse(string(tpl))
	if err != nil {
		return err
	}

	var buffer bytes.Buffer
	if err := tmpl.ExecuteTemplate(&buffer, name, distros); err != nil {
		return err
	}

	newpath := filepath.Join(".", "generated")
	if err := os.MkdirAll(newpath, os.ModePerm); err != nil {
		return err
	}

	return os.WriteFile(fmt.Sprintf("generated/%s.yml", name), buffer.Bytes(), 0644)
}
