#define Uses_TKeys
#define Uses_TApplication
#define Uses_TEvent
#define Uses_TMenuBar
#define Uses_TSubMenu
#define Uses_TMenuItem
#define Uses_TStatusLine
#define Uses_TStatusItem
#define Uses_TStatusDef
#define Uses_MsgBox
#define Uses_TDeskTop
#include <tvision/tv.h>
#include "sql.h"

class TEventViewer;
constexpr ushort
    cmDBOpen        = 200,
    cmListSave      = 201,
    cmDBBackup      = 202,
    cmFilmsShow     = 203,
    cmFilmNew       = 204,
    cmGenresShow    = 205,
    cmGenreNew      = 206,
    cmDirectorsShow = 207,
    cmDirectorNew   = 208,
    cmTagsShow      = 209,
    cmTagNew        = 210,
    cmCountriesShow = 211,
    cmCountryNew    = 212,
    cmAboutBox      = 2000;

    char aboutMsg[80] =  "\x3 Cinem 0.01 \n\n\x3 Films database application";
    const char *dbname    = "films.db";
    const char *query_sys = "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name;";

class TCinemApp : public TApplication
{
private:
    void about_viewer();
public:
    TCinemApp();
    virtual void handleEvent( TEvent& event );
    static TMenuBar *initMenuBar( TRect );
    static TStatusLine *initStatusLine( TRect );
};

TCinemApp::TCinemApp() :
    TProgInit( &TCinemApp::initStatusLine,
               &TCinemApp::initMenuBar,
               &TCinemApp::initDeskTop
             )
{
}

void TCinemApp::handleEvent( TEvent& event )
{
    TApplication::handleEvent( event );
    if( event.what == evCommand )
    {
        switch( event.message.command )
        {
            case cmAboutBox:
                messageBox(aboutMsg, mfInformation | mfOKButton);
                break;
            case cmFilmsShow:
                about_viewer();
                break;
            default:
                break;
        }
    }
}

TMenuBar *TCinemApp::initMenuBar( TRect r )
{
    r.b.y = r.a.y+1;
    return new TMenuBar( r,
        *new TSubMenu( "~F~ile", hcNoContext ) +
            *new TMenuItem("~O~pen DB...", cmDBOpen, kbNoKey, hcNoContext, "" ) +
            *new TMenuItem( "~B~ackup BD", cmDBBackup, kbNoKey, hcNoContext, "") +
            newLine() +
            *new TMenuItem( "~A~bout...", cmAboutBox, kbNoKey, hcNoContext ) +
            newLine() +
            *new TMenuItem( "E~x~it", cmQuit, cmQuit, hcNoContext )+
        *new TSubMenu( "Films", hcNoContext) +
            *new TMenuItem( "All films", cmFilmsShow, kbNoKey, hcNoContext, "") +
            *new TMenuItem( "New film...", cmFilmNew, kbNoKey, hcNoContext, "") +
        *new TSubMenu( "~G~enres", hcNoContext ) +
            *new TMenuItem( "All genres", cmGenresShow, kbNoKey, hcNoContext, "") +
            *new TMenuItem( "New genre...", cmGenreNew, kbNoKey, hcNoContext, "") +   
        *new TSubMenu( "~D~irectors", hcNoContext) +
            *new TMenuItem( "All directors", cmDirectorsShow, kbNoKey, hcNoContext, "")+
            *new TMenuItem( "New director...", cmDirectorNew, kbNoKey, hcNoContext, "")+
         *new TSubMenu( "~C~ountries", hcNoContext) +
            *new TMenuItem( "All countries", cmCountriesShow, kbNoKey, hcNoContext, "")+
            *new TMenuItem( "New country...", cmCountryNew, kbNoKey, hcNoContext, "")+
         *new TSubMenu( "~T~ags", hcNoContext) +
            *new TMenuItem( "All tags", cmTagsShow, kbNoKey, hcNoContext, "")+
            *new TMenuItem( "New tag...", cmTagNew, kbNoKey, hcNoContext, "")
        );
}

TStatusLine *TCinemApp::initStatusLine( TRect r )
{
    r.a.y = r.b.y-1;
    return new TStatusLine( r,
        *new TStatusDef( 0, 0xFFFF ) +
            *new TStatusItem( "~Alt-X~ Exit", kbAltX, cmQuit ) +
            *new TStatusItem( 0, kbF10, cmMenu )
            );
}

void TCinemApp::about_viewer()
{
    TRect *r;
    r = new TRect(0,0,60,60);
    TWindow *viewer = (TWindow *)  message(0, evBroadcast, cmFilmsShow, 0);
    deskTop->insert((TView*)viewer);
}

int main()
{
    Database db(dbname);
    TCinemApp cinemApp;
    cinemApp.run();
    return 0;
}
