package repository

import (
	"database/sql"
	"reportandil/models"
)

type UserRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) CreateUser(user *models.User) error {
	_, err := r.db.Exec("INSERT INTO users (name, email) values ($1, $2)", user.Name, user.Email)
	if err != nil {
		return err
	}
	return nil
}

func (r *UserRepository) GetUserByID(id int) (*models.User, error){
	row := r.db.QueryRow("SELECT id, name, email FROM users WHERE id = $1", id)
	user := &models.User{}
	err := row.Scan(&user.ID, &user.Name, &user.Email)
	if err != nil {
		return nil, err
	}
	return user, nil
}

func (r *UserRepository) ListUsers() ([]*models.User, error){
	rows, err := r.db.Query("SELECT id, name, email FROM users")
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var users []*models.User

	for rows.Next(){
		u := &models.User{}
		err := rows.Scan(&u.ID, &u.Name, &u.Email)
		if err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	return users, rows.Err()
}

func (r *UserRepository) UpdateUser(user *models.User) error{
	_, err := r.db.Exec("UPDATE users SET name = $2, email = $3 WHERE id = $1", user.ID, user.Name, user.Email)
	if err != nil {
		return err
	}
	return nil
}

func (r *UserRepository) DeleteUser(id int) error{
	_, err := r.db.Exec("DELETE FROM users WHERE id = $1", id)
	if err != nil {
		return err
	}
	return nil
}
