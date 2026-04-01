#include "sql.h"
#include <iostream>

Database::Database(const std::string& dbname) : db(nullptr), is_open(false)
{
    int rc = sqlite3_open(dbname.c_str(), &db);
    if (rc != SQLITE_OK)
    {
        std::cerr << "Can't open database '" << dbname << "': " << sqlite3_errmsg(db) << "\n";
        db = nullptr;
        is_open = false;
    }
    else
    {
        is_open = true;
    }
}

Database::~Database()
{
    if (db)
    {
        sqlite3_close(db);
    }
}

int Database::execute(const std::string& query)
{
    if (!is_open) return 1;

    sqlite3_stmt* stmt;
    int rc = sqlite3_prepare_v2(db, query.c_str(), -1, &stmt, nullptr);
    if (rc != SQLITE_OK)
    {
        std::cerr << "Failed to prepare statement: " << sqlite3_errmsg(db) << "\n";
        return 1;
    }

    int cols = sqlite3_column_count(stmt);
    while (sqlite3_step(stmt) == SQLITE_ROW)
    {
        for (int i = 0; i < cols; i++)
        {
            const char* text = reinterpret_cast<const char*>(sqlite3_column_text(stmt, i));
            std::cout << (text ? text : "NULL") << "\t";
        }
        std::cout << "\n";
    }

    sqlite3_finalize(stmt);
    return 0;
}

