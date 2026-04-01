#pragma once
#include <sqlite3.h>
#include <string>

class Database {
public:
    Database(const std::string& dbname);

    ~Database();

    int execute(const std::string& query);

private:
    sqlite3* db;
    bool is_open;
};
