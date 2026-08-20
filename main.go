package main

import (
	"fmt"
	"net/http"
)

func serveHome(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	http.ServeFile(w, r, "./index.html")
}

func main() {
	staticDir := "./static"
	fileServer := http.FileServer(http.Dir(staticDir))
	http.Handle("/static/", http.StripPrefix("/static/", fileServer)) // Preguntar: que es StripPrefix

	http.HandleFunc("/", serveHome)
	port := ":8080"
	fmt.Printf("Server running localhost%s", port)
	err := http.ListenAndServe(port, nil)
	if err != nil {
		fmt.Printf("Error %s", err)
	}
}
