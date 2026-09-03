package crudgorm

import (
	"fmt"
	"log"
	modelsgorm "reportandil/modelsGORM"

	"gorm.io/gorm"
)

/*
• Crear: db.Create(&User{...})
• Leer (uno): db.First(&user, 1)
• Leer (todos): db.Find(&users)
• Actualizar: db.Model(&user).Update("name", "new_name")
• Eliminar: db.Delete(&User{}, 1)
*/
func CreateUser(db *gorm.DB, u *modelsgorm.User) {
	result := db.Create(&u) // Pasa el puntero del objeto
	if result.Error != nil {
		log.Fatalf("failed to create user: %v", result.Error)
	}
	fmt.Printf("Usuario creado con ID: %d", u.ID)
}

func ReadUser(db *gorm.DB, id int) *modelsgorm.User {
	u := &modelsgorm.User{}
	result := db.First(u, id)
	if result.Error != nil {
		log.Fatalf("failed to read user: %v", result.Error)
	}
	fmt.Printf("Usuario leido. ID: %d, Nombre: %s, Email: %s", u.ID, u.Name, u.Email)
	return u
}

func ListUsers(db *gorm.DB) {
	users := &[]modelsgorm.User{}
	db.Find(users)
	fmt.Printf("Lista de usuarios: %+v ", users)
}

func UpdateUser(db *gorm.DB, u *modelsgorm.User, new_name string) {
	db.Model(u).Update("name", new_name)
	fmt.Printf("Usuario actualizado: %+v ", u)
}

func DeleteUser(db *gorm.DB, id int) {
	db.Delete(&modelsgorm.User{}, id)
	fmt.Printf("Usuario eliminado")
}
