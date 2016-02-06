/*

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

*/
module derelict.pq.pq;

private {
    import derelict.util.loader;
    import derelict.util.system;
    import derelict.util.exception;

    static if( Derelict_OS_Windows )
        enum libNames = "libpq.dll";
    else static if( Derelict_OS_Mac )
        enum libNames = "libpq.dylib";
    else static if( Derelict_OS_Posix )
        enum libNames = "libpq.so";
    else
        static assert( 0, "Need to implement PostgreSQL libNames for this operating system." );
}

alias Oid = uint;
alias pqbool = char;
alias pg_int64 = long;
public import core.stdc.stdio : FILE;

enum {
    PG_COPYRES_ATTRS       = 0x01,
    PG_COPYRES_TUPLES      = 0x02,
    PG_COPYRES_EVENTS      = 0x04,
    PG_COPYRES_NOTICEHOOKS = 0x08,
}

alias ConnStatusType = int;
enum {
    CONNECTION_OK,
    CONNECTION_BAD,
    CONNECTION_STARTED,
    CONNECTION_MADE,
    CONNECTION_AWAITIN_RESPONSE,
    CONNECTION_AUTH_OK,
    CONNECTION_SETENV,
    CONNECTION_SSL_STARTUP,
    CONNECTION_NEEDED
}

alias PostgresPollingStatusType = int;
enum {
    PGRES_POLLING_FAILED = 0,
    PGRES_POLLING_READING,
    PGRES_POLLING_WRITING,
    PGRES_POLLING_OK,
    PGRES_POLLING_ACTIVE
}

alias ExecStatusType = int;
enum {
    PGRES_EMPTY_QUERY = 0,
    PGRES_COMMAND_OK,
    PGRES_TUPLES_OK,
    PGRES_COPY_OUT,
    PGRES_COPY_IN,
    PGRES_BAD_RESPONSE,
    PGRES_NONFATAL_ERROR,
    PGRES_FATAL_ERROR,
    PGRES_COPY_BOTH,
    PGRES_SINGLE_TUPLE
}

alias PGTransactionStatusType = int;
enum {
    PQTRANS_IDLE,
    PQTRANS_ACTIVE,
    PQTRANS_INTRANS,
    PQTRANS_INERROR,
    PQTRANS_UNKNOWN
}

alias PGVerbosity = int;
enum {
    PQERRORS_TERSE,
    PQERRORS_DEFAULT,
    PQERRORS_VERBOSE
}

alias PGPing = int;
enum {
    PQPING_OK,
    PQPING_REJECT,
    PQPING_NO_RESPONSE,
    PQPING_NO_ATTEMTP
}

struct PGconn;
struct PGresult;
struct PGcancel;

struct PGnotify {
    char* relname;
    int be_pid;
    char* extra;
    private PGnotify* next;
}

extern( C ) @nogc nothrow {
    alias PQnoticeReceiver = void function( void*,PGresult* );
    alias PQnoticeProcessor = void function( void*,char* );
}

struct PQprintOpt {
    pqbool header;
    pqbool aligment;
    pqbool standard;
    pqbool html3;
    pqbool expander;
    pqbool pager;
    char* fieldSep;
    char* tableOpt;
    char* caption;
    char** fieldName;
}

struct PQconninfoOption {
    char* keyword;
    char* envvar;
    char* compiled;
    char* val;
    char* label;
    char* dispchar;
    int dispsize;
}

struct PQArgBlock {
    int len;
    int ising;
    union u
    {
        int* ptr;
        int integer;
    }
}

struct PGresAttDesc {
    char* name;
    Oid tableid;
    int columnid;
    int format;
    Oid typid;
    int typlen;
    int atttypmod;
}

alias PGEventId = int;
enum {
    PGEVT_REGISTER,
    PGEVT_CONNRESET,
    PGEVT_CONNDESTROY,
    PGEVT_RESULTCREATE,
    PGEVT_RESULTCOPY,
    PGEVT_RESULTDESTROY
}

struct PGEventResultCreate {
    PGconn* conn;
    PGresult* result;
}

extern( C ) @nogc nothrow {
    alias pgthreadlock_t = void function( int );
    alias PGEventProc = size_t function( PGEventId,void*,void* );
}

// from postgres_ext.h
enum : int {
    PG_DIAG_SEVERITY =          'S',
    PG_DIAG_SQLSTATE =          'C',
    PG_DIAG_MESSAGE_PRIMARY =   'M',
    PG_DIAG_MESSAGE_DETAIL =    'D',
    PG_DIAG_MESSAGE_HINT =      'H',
    PG_DIAG_STATEMENT_POSITION ='P',
    PG_DIAG_INTERNAL_POSITION = 'p',
    PG_DIAG_INTERNAL_QUERY =    'q',
    PG_DIAG_CONTEXT =           'W',
    PG_DIAG_SCHEMA_NAME =       's',
    PG_DIAG_TABLE_NAME =        't',
    PG_DIAG_COLUMN_NAME =       'c',
    PG_DIAG_DATATYPE_NAME =     'd',
    PG_DIAG_CONSTRAINT_NAME =   'n',
    PG_DIAG_SOURCE_FILE =       'F',
    PG_DIAG_SOURCE_LINE =       'L',
    PG_DIAG_SOURCE_FUNCTION =   'R'
}  

extern( C ) @nogc nothrow {
    alias da_PQconnectStart = PGconn* function( char* );
    alias da_PQconnectStartParams = PGconn* function( char**,char**,int );
    alias da_PQconnectPoll = PostgresPollingStatusType function( PGconn* );

    alias da_PQconnectdb = PGconn* function( const(  char  )*  );
    alias da_PQconnectdbParams = PGconn* function( char**,char**,int );
    alias da_PQsetdbLogin = PGconn* function( char*,char*,char*,char*,char*,char*,char* );

    alias da_PQfinish = void function( PGconn* );

    alias da_PQconndefaults = PQconninfoOption* function(  );
    alias da_PQconninfoParse = PQconninfoOption* function( char*,char** );
    alias da_PQconninfo = PQconninfoOption* function( PGconn* );
    alias da_PQconninfoFree = void function( PQconninfoOption* );

    alias da_PQresetStart = int function( PGconn* );
    alias da_PQresetPoll = PostgresPollingStatusType function( PGconn* );
    alias da_PQreset = void function( PGconn* );

    alias da_PQgetCancel = PGcancel* function( PGconn* );
    alias da_PQfreeCancel = void function( PGcancel* );
    alias da_PQcancel = int function( PGcancel*,char*,int );
    alias da_PQrequestCancel = int function( PGconn* );

    alias da_PQdb = char* function( PGconn* );
    alias da_PQuser = char* function( PGconn* );
    alias da_PQpass = char* function( PGconn* );
    alias da_PQhost = char* function( PGconn* );
    alias da_PQport = char* function( PGconn* );
    alias da_PQtty = char* function( PGconn* );
    alias da_PQoptions = char* function( PGconn* );
    alias da_PQstatus = ConnStatusType function( PGconn* );

    alias da_PQtransactionStatus = PGTransactionStatusType function( PGconn* );
    alias da_PQparameterStatus = char* function( PGconn*,char* );
    alias da_PQprotocolVersion = int function( PGconn* );
    alias da_PQserverVersion = int function( PGconn* );
    alias da_PQerrorMessage = char* function( PGconn* );
    alias da_PQsocket = int function( PGconn* );
    alias da_PQbackendPID = int function( PGconn* );
    alias da_PQconnectionNeedsPassword = int function( PGconn* );
    alias da_PQconnectionUsedPassword = int function( PGconn* );
    alias da_PQclientEncoding = int function( PGconn* );
    alias da_PQsetClientEncoding = int function( PGconn*,char* );

    alias da_PQgetssl = void* function( PGconn* );
    alias da_PQinitSSL = void function( int );
    alias da_PQinitOpenSSL = void function( int,int );

    alias da_PQsetErrorVerbosity = PGVerbosity function( PGconn*,PGVerbosity );
    alias da_PQtrace = void function( PGconn*,FILE* );
    alias da_PQuntrace = void function( PGconn* );

    alias da_PQsetNoticeReceiver = PQnoticeReceiver function( PGconn*,PQnoticeReceiver,void* );
    alias da_PQsetNoticeProcessor = PQnoticeProcessor function( PGconn*,PQnoticeProcessor,void* );

    alias da_PQregisterThreadLock = pgthreadlock_t function( pgthreadlock_t );

    alias da_PQexec = PGresult* function( PGconn*,const( char )* );
    alias da_PQexecParams = PGresult* function( PGconn*,const( char )*,int,Oid*,const( ubyte )**,int*,int*,int );
    alias da_PQprepare = PGresult* function( PGconn*,char*,char*,int,Oid* );
    alias da_PQexecPrepared = PGresult* function( PGconn*,char*,int,char**,int*,int*,int );
    alias da_PQsendQuery = int function( PGconn*,const( char )* );
    alias da_PQsendQueryParams = int function( PGconn*,const( char )*,int,Oid*,const( ubyte )**,int*,int*,int );
    alias da_PQsendPrepare = int function( PGconn*,char*,char*,int,Oid* );
    alias da_PQsendQueryPrepared = int function( PGconn*,char*,int,char**,int*,int*,int );
    alias da_PQsetSingleRowMode = int function( PGconn* );
    alias da_PQgetResult = PGresult* function( PGconn* );

    alias da_PQisBusy = int function( PGconn* );
    alias da_PQconsumeInput = int function( PGconn* );

    alias da_PQnotifies = immutable ( PGnotify )* function( PGconn* );

    alias da_PQputCopyData = int function( PGconn*,char*,int );
    alias da_PQputCopyEnd = int function( PGconn*,char* );
    alias da_PQgetCopyData = int function( PGconn*,char**,int );

    alias da_PQgetline = int function( PGconn*,char*,int );
    alias da_PQputline = int function( PGconn*,char* );
    alias da_PQgetlineAsync = int function( PGconn*,char*,int );
    alias da_PQputnbytes = int function( PGconn*,char*,int );
    alias da_PQendcopy = int function( PGconn* );

    alias da_PQsetnonblocking = int function( PGconn*,int );
    alias da_PQisnonblocking = int function( PGconn* );
    alias da_PQisthreadsafe = int function(  );
    alias da_PQping = PGPing function( char* );
    alias da_PQpingParams = PGPing function( char**,char**,int );

    alias da_PQflush = int function( PGconn* );

    alias da_PQfn = PGresult* function( PGconn*,int,int*,int*,int,PQArgBlock*,int );
    alias da_PQresultStatus = ExecStatusType function( const( PGresult )* );
    alias da_PQresStatus = char* function( ExecStatusType );
    alias da_PQresultErrorMessage = char* function( const( PGresult )* );
    alias da_PQresultErrorField = char* function( const( PGresult )*,int );
    alias da_PQntuples = int function( const( PGresult )* );
    alias da_PQnfields = int function( const( PGresult )* );
    alias da_PQbinaryTuples = int function( PGresult* );
    alias da_PQfname = char* function( PGresult*,int );
    alias da_PQfnumber = int function( const( PGresult )*,const( char )* );
    alias da_PQftable = Oid function( PGresult*,int );
    alias da_PQftablecol = int function( PGresult*,int );
    alias da_PQfformat = int function( const( PGresult )*,int );
    alias da_PQftype = Oid function( const( PGresult )*,int );
    alias da_PQfsize = int function( PGresult*,int );
    alias da_PQfmod = int function( PGresult*,int );
    alias da_PQcmdStatus = char* function( const( PGresult )* );
    alias da_PQoidStatus = char* function( PGresult* );
    alias da_PQoidValue = Oid function( PGresult* );
    alias da_PQcmdTuples = char* function( PGresult* );
    alias da_PQgetvalue = const( ubyte )* function( const( PGresult )*,int,int );
    alias da_PQgetlength = int function( const( PGresult )*,int,int );
    alias da_PQgetisnull = int function( const( PGresult )*,int,int );
    alias da_PQnparams = int function( PGresult* );
    alias da_PQparamtype = Oid function( PGresult*,int );

    alias da_PQdescribePrepared = PGresult* function( PGconn*,char* );
    alias da_PQdescribePortal = PGresult* function( PGconn*,char* );
    alias da_PQsendDescribePrepared = int function( PGconn*,char* );
    alias da_PQsendDescribePortal = int function( PGconn*,char* );

    alias da_PQclear = void function( const( PGresult )* );
    alias da_PQfreemem = void function( void* );

    alias da_PQmakeEmptyPGresult = PGresult* function( PGconn*,ExecStatusType );
    alias da_PQcopyResult = PGresult* function( const( PGresult )*,int );
    alias da_PQsetResultAttrs = int function( PGresult*,int,PGresAttDesc* );
    alias da_PQresultAlloc = void* function( PGresult*,size_t );
    alias da_PQsetvalue = int function( PGresult*,int,int,char*,int );

    alias da_PQescapeStringConn = size_t function( PGconn*,char*,char*,size_t,int* );
    alias da_PQescapeLiteral = char* function( PGconn*,const( char )*,size_t );
    alias da_PQescapeIdentifier = char* function( PGconn*,const( char )*,size_t );
    alias da_PQescapeByteaConn = ubyte* function( PGconn*,ubyte*,size_t,size_t* );
    alias da_PQunescapeBytea = ubyte* function( ubyte*,size_t* );

    alias da_PQescapeString = size_t function( char*,char*,size_t );
    alias da_PQescapeBytea = ubyte* function( ubyte*,size_t,size_t* );

    alias da_PQprint = void function( FILE*,PGresult*,PQprintOpt* );
    alias da_PQdisplayTuples = void function( PGresult*,FILE*,int,char*,int,int );
    alias da_PQprintTuples = void function( PGresult*,FILE*,int,int,int );

    alias da_lo_open = int function( PGconn*,Oid,int );
    alias da_lo_close = int function( PGconn*,int );
    alias da_lo_read = int function( PGconn*,int,char*,size_t );
    alias da_lo_write = int function( PGconn*,int,const( char )*,size_t );
    alias da_lo_lseek = int function( PGconn*,int,int,int );
    alias da_lo_lseek64 = pg_int64 function( PGconn*,int,pg_int64,int );
    alias da_lo_creat = Oid function( PGconn*,int );
    alias da_lo_create = Oid function( PGconn*,Oid );
    alias da_lo_tell = int function( PGconn*,int );
    alias da_lo_tell64 = pg_int64 function( PGconn*,int );
    alias da_lo_truncate = int function( PGconn*,int,size_t );
    alias da_lo_truncate64 = int function( PGconn*,int,pg_int64 );
    alias da_lo_unlink = int function( PGconn*,Oid );
    alias da_lo_import = Oid function( PGconn*,const( char )* );
    alias da_lo_import_with_oid = Oid function( PGconn*,const( char )*,Oid );
    alias da_lo_export = int function( PGconn*,Oid,const( char )* );

    alias da_PQlibVersion = int function(  );
    alias da_PQmblen = int function( char*,int );
    alias da_PQdsplen = int function( char*,int );
    alias da_PQenv2encoding = int function(  );
    alias da_PQencryptPassword = char* function( char*,char* );

    alias da_pg_char_to_encoding = int function( const( char )* );
    alias da_pg_encoding_to_char = const( char )* function( int );
    alias da_pg_valid_server_encoding_id = int function( int );

    alias da_PQregisterEventProc = int function( PGconn*,PGEventProc,const( char )*,void* );
    alias da_PQsetInstanceData = int function( PGconn*,PGEventProc,void* );
}

__gshared
{
    da_PQconnectStart PQconnectStart;
    da_PQconnectStartParams PQconnectStartParams;
    da_PQconnectPoll PQconnectPoll;
    da_PQconnectdb PQconnectdb;
    da_PQconnectdbParams PQconnectdbParams;
    da_PQsetdbLogin PQsetdbLogin;
    da_PQfinish PQfinish;
    da_PQconndefaults PQconndefaults;
    da_PQconninfoParse PQconninfoParse;
    da_PQconninfo PQconninfo;
    da_PQconninfoFree PQconninfoFree;
    da_PQresetStart PQresetStart;
    da_PQresetPoll PQresetPoll;
    da_PQreset PQreset;
    da_PQgetCancel PQgetCancel;
    da_PQfreeCancel PQfreeCancel;
    da_PQcancel PQcancel;
    da_PQrequestCancel PQrequestCancel;
    da_PQdb PQdb;
    da_PQuser PQuser;
    da_PQpass PQpass;
    da_PQhost PQhost;
    da_PQport PQport;
    da_PQtty PQtty;
    da_PQoptions PQoptions;
    da_PQstatus PQstatus;
    da_PQtransactionStatus PQtransactionStatus;
    da_PQparameterStatus PQparameterStatus;
    da_PQprotocolVersion PQprotocolVersion;
    da_PQserverVersion PQserverVersion;
    da_PQerrorMessage PQerrorMessage;
    da_PQsocket PQsocket;
    da_PQbackendPID PQbackendPID;
    da_PQconnectionNeedsPassword PQconnectionNeedsPassword;
    da_PQconnectionUsedPassword PQconnectionUsedPassword;
    da_PQclientEncoding PQclientEncoding;
    da_PQsetClientEncoding PQsetClientEncoding;
    da_PQgetssl PQgetssl;
    da_PQinitSSL PQinitSSL;
    da_PQinitOpenSSL PQinitOpenSSL;
    da_PQsetErrorVerbosity PQsetErrorVerbosity;
    da_PQtrace PQtrace;
    da_PQuntrace PQuntrace;
    da_PQsetNoticeReceiver PQsetNoticeReceiver;
    da_PQsetNoticeProcessor PQsetNoticeProcessor;
    da_PQregisterThreadLock PQregisterThreadLock;
    da_PQexec PQexec;
    da_PQexecParams PQexecParams;
    da_PQprepare PQprepare;
    da_PQexecPrepared PQexecPrepared;
    da_PQsendQuery PQsendQuery;
    da_PQsendQueryParams PQsendQueryParams;
    da_PQsendPrepare PQsendPrepare;
    da_PQsendQueryPrepared PQsendQueryPrepared;
    da_PQsetSingleRowMode PQsetSingleRowMode;
    da_PQgetResult PQgetResult;
    da_PQisBusy PQisBusy;
    da_PQconsumeInput PQconsumeInput;
    da_PQnotifies PQnotifies;
    da_PQputCopyData PQputCopyData;
    da_PQputCopyEnd PQputCopyEnd;
    da_PQgetCopyData PQgetCopyData;
    da_PQgetline PQgetline;
    da_PQputline PQputline;
    da_PQgetlineAsync PQgetlineAsync;
    da_PQputnbytes PQputnbytes;
    da_PQendcopy PQendcopy;
    da_PQsetnonblocking PQsetnonblocking;
    da_PQisnonblocking PQisnonblocking;
    da_PQisthreadsafe PQisthreadsafe;
    da_PQping PQping;
    da_PQpingParams PQpingParams;
    da_PQflush PQflush;
    da_PQfn PQfn;
    da_PQresultStatus PQresultStatus;
    da_PQresStatus PQresStatus;
    da_PQresultErrorMessage PQresultErrorMessage;
    da_PQresultErrorField PQresultErrorField;
    da_PQntuples PQntuples;
    da_PQnfields PQnfields;
    da_PQbinaryTuples PQbinaryTuples;
    da_PQfname PQfname;
    da_PQfnumber PQfnumber;
    da_PQftable PQftable;
    da_PQftablecol PQftablecol;
    da_PQfformat PQfformat;
    da_PQftype PQftype;
    da_PQfsize PQfsize;
    da_PQfmod PQfmod;
    da_PQcmdStatus PQcmdStatus;
    da_PQoidStatus PQoidStatus;
    da_PQoidValue PQoidValue;
    da_PQcmdTuples PQcmdTuples;
    da_PQgetvalue PQgetvalue;
    da_PQgetlength PQgetlength;
    da_PQgetisnull PQgetisnull;
    da_PQnparams PQnparams;
    da_PQparamtype PQparamtype;
    da_PQdescribePrepared PQdescribePrepared;
    da_PQdescribePortal PQdescribePortal;
    da_PQsendDescribePrepared PQsendDescribePrepared;
    da_PQsendDescribePortal PQsendDescribePortal;
    da_PQclear PQclear;
    da_PQfreemem PQfreemem;
    da_PQmakeEmptyPGresult PQmakeEmptyPGresult;
    da_PQcopyResult PQcopyResult;
    da_PQsetResultAttrs PQsetResultAttrs;
    da_PQresultAlloc PQresultAlloc;
    da_PQsetvalue PQsetvalue;
    da_PQescapeStringConn PQescapeStringConn;
    da_PQescapeLiteral PQescapeLiteral;
    da_PQescapeIdentifier PQescapeIdentifier;
    da_PQescapeByteaConn PQescapeByteaConn;
    da_PQunescapeBytea PQunescapeBytea;
    da_PQescapeString PQescapeString;
    da_PQescapeBytea PQescapeBytea;
    da_PQprint PQprint;
    da_PQdisplayTuples PQdisplayTuples;
    da_PQprintTuples PQprintTuples;
    da_lo_open lo_open;
    da_lo_close lo_close;
    da_lo_read lo_read;
    da_lo_write lo_write;
    da_lo_lseek lo_lseek;
    da_lo_lseek64 lo_lseek64;
    da_lo_creat lo_creat;
    da_lo_create lo_create;
    da_lo_tell lo_tell;
    da_lo_tell64 lo_tell64;
    da_lo_truncate lo_truncate;
    da_lo_truncate64 lo_truncate64;
    da_lo_unlink lo_unlink;
    da_lo_import lo_import;
    da_lo_import_with_oid lo_import_with_oid;
    da_lo_export lo_export;
    da_PQlibVersion PQlibVersion;
    da_PQmblen PQmblen;
    da_PQdsplen PQdsplen;
    da_PQenv2encoding PQenv2encoding;
    da_PQencryptPassword PQencryptPassword;
    da_pg_char_to_encoding pg_char_to_encoding;
    da_pg_encoding_to_char pg_encoding_to_char;
    da_pg_valid_server_encoding_id pg_valid_server_encoding_id;
    da_PQregisterEventProc PQregisterEventProc;
    da_PQsetInstanceData PQsetInstanceData;
}


class DerelictPQLoader : SharedLibLoader {
    public this() {
        super( libNames );
    }

    protected override void loadSymbols()
    {
        bindFunc( cast( void** )&PQconnectStart, "PQconnectStart" );
        bindFunc( cast( void** )&PQconnectStartParams, "PQconnectStartParams" );
        bindFunc( cast( void** )&PQconnectPoll, "PQconnectPoll" );
        bindFunc( cast( void** )&PQconnectdb, "PQconnectdb" );
        bindFunc( cast( void** )&PQconnectdbParams, "PQconnectdbParams" );
        bindFunc( cast( void** )&PQsetdbLogin, "PQsetdbLogin" );
        bindFunc( cast( void** )&PQfinish, "PQfinish" );
        bindFunc( cast( void** )&PQconndefaults, "PQconndefaults" );
        bindFunc( cast( void** )&PQconninfoParse, "PQconninfoParse" );
        bindFunc( cast( void** )&PQconninfoFree, "PQconninfoFree" );
        bindFunc( cast( void** )&PQresetStart, "PQresetStart" );
        bindFunc( cast( void** )&PQresetPoll, "PQresetPoll" );
        bindFunc( cast( void** )&PQreset, "PQreset" );
        bindFunc( cast( void** )&PQgetCancel, "PQgetCancel" );
        bindFunc( cast( void** )&PQfreeCancel, "PQfreeCancel" );
        bindFunc( cast( void** )&PQcancel, "PQcancel" );
        bindFunc( cast( void** )&PQrequestCancel, "PQrequestCancel" );
        bindFunc( cast( void** )&PQdb, "PQdb" );
        bindFunc( cast( void** )&PQuser, "PQuser" );
        bindFunc( cast( void** )&PQpass, "PQpass" );
        bindFunc( cast( void** )&PQhost, "PQhost" );
        bindFunc( cast( void** )&PQport, "PQport" );
        bindFunc( cast( void** )&PQtty, "PQtty" );
        bindFunc( cast( void** )&PQoptions, "PQoptions" );
        bindFunc( cast( void** )&PQstatus, "PQstatus" );
        bindFunc( cast( void** )&PQtransactionStatus, "PQtransactionStatus" );
        bindFunc( cast( void** )&PQparameterStatus, "PQparameterStatus" );
        bindFunc( cast( void** )&PQprotocolVersion, "PQprotocolVersion" );
        bindFunc( cast( void** )&PQserverVersion, "PQserverVersion" );
        bindFunc( cast( void** )&PQerrorMessage, "PQerrorMessage" );
        bindFunc( cast( void** )&PQsocket, "PQsocket" );
        bindFunc( cast( void** )&PQbackendPID, "PQbackendPID" );
        bindFunc( cast( void** )&PQconnectionNeedsPassword, "PQconnectionNeedsPassword" );
        bindFunc( cast( void** )&PQconnectionUsedPassword, "PQconnectionUsedPassword" );
        bindFunc( cast( void** )&PQclientEncoding, "PQclientEncoding" );
        bindFunc( cast( void** )&PQsetClientEncoding, "PQsetClientEncoding" );
        bindFunc( cast( void** )&PQgetssl, "PQgetssl" );
        bindFunc( cast( void** )&PQinitSSL, "PQinitSSL" );
        bindFunc( cast( void** )&PQinitOpenSSL, "PQinitOpenSSL" );
        bindFunc( cast( void** )&PQsetErrorVerbosity, "PQsetErrorVerbosity" );
        bindFunc( cast( void** )&PQtrace, "PQtrace" );
        bindFunc( cast( void** )&PQuntrace, "PQuntrace" );
        bindFunc( cast( void** )&PQsetNoticeReceiver, "PQsetNoticeReceiver" );
        bindFunc( cast( void** )&PQsetNoticeProcessor, "PQsetNoticeProcessor" );
        bindFunc( cast( void** )&PQregisterThreadLock, "PQregisterThreadLock" );
        bindFunc( cast( void** )&PQexec, "PQexec" );
        bindFunc( cast( void** )&PQexecParams, "PQexecParams" );
        bindFunc( cast( void** )&PQprepare, "PQprepare" );
        bindFunc( cast( void** )&PQexecPrepared, "PQexecPrepared" );
        bindFunc( cast( void** )&PQsendQuery, "PQsendQuery" );
        bindFunc( cast( void** )&PQsendQueryParams, "PQsendQueryParams" );
        bindFunc( cast( void** )&PQsendPrepare, "PQsendPrepare" );
        bindFunc( cast( void** )&PQsendQueryPrepared, "PQsendQueryPrepared" );
        bindFunc( cast( void** )&PQgetResult, "PQgetResult" );
        bindFunc( cast( void** )&PQisBusy, "PQisBusy" );
        bindFunc( cast( void** )&PQconsumeInput, "PQconsumeInput" );
        bindFunc( cast( void** )&PQnotifies, "PQnotifies" );
        bindFunc( cast( void** )&PQputCopyData, "PQputCopyData" );
        bindFunc( cast( void** )&PQputCopyEnd, "PQputCopyEnd" );
        bindFunc( cast( void** )&PQgetCopyData, "PQgetCopyData" );
        bindFunc( cast( void** )&PQgetline, "PQgetline" );
        bindFunc( cast( void** )&PQputline, "PQputline" );
        bindFunc( cast( void** )&PQgetlineAsync, "PQgetlineAsync" );
        bindFunc( cast( void** )&PQputnbytes, "PQputnbytes" );
        bindFunc( cast( void** )&PQendcopy, "PQendcopy" );
        bindFunc( cast( void** )&PQsetnonblocking, "PQsetnonblocking" );
        bindFunc( cast( void** )&PQisnonblocking, "PQisnonblocking" );
        bindFunc( cast( void** )&PQisthreadsafe, "PQisthreadsafe" );
        bindFunc( cast( void** )&PQping, "PQping" );
        bindFunc( cast( void** )&PQpingParams, "PQpingParams" );
        bindFunc( cast( void** )&PQflush, "PQflush" );
        bindFunc( cast( void** )&PQfn, "PQfn" );
        bindFunc( cast( void** )&PQresultStatus, "PQresultStatus" );
        bindFunc( cast( void** )&PQresStatus, "PQresStatus" );
        bindFunc( cast( void** )&PQresultErrorMessage, "PQresultErrorMessage" );
        bindFunc( cast( void** )&PQresultErrorField, "PQresultErrorField" );
        bindFunc( cast( void** )&PQntuples, "PQntuples" );
        bindFunc( cast( void** )&PQnfields, "PQnfields" );
        bindFunc( cast( void** )&PQbinaryTuples, "PQbinaryTuples" );
        bindFunc( cast( void** )&PQfname, "PQfname" );
        bindFunc( cast( void** )&PQfnumber, "PQfnumber" );
        bindFunc( cast( void** )&PQftable, "PQftable" );
        bindFunc( cast( void** )&PQftablecol, "PQftablecol" );
        bindFunc( cast( void** )&PQfformat, "PQfformat" );
        bindFunc( cast( void** )&PQftype, "PQftype" );
        bindFunc( cast( void** )&PQfsize, "PQfsize" );
        bindFunc( cast( void** )&PQfmod, "PQfmod" );
        bindFunc( cast( void** )&PQcmdStatus, "PQcmdStatus" );
        bindFunc( cast( void** )&PQoidStatus, "PQoidStatus" );
        bindFunc( cast( void** )&PQoidValue, "PQoidValue" );
        bindFunc( cast( void** )&PQcmdTuples, "PQcmdTuples" );
        bindFunc( cast( void** )&PQgetvalue, "PQgetvalue" );
        bindFunc( cast( void** )&PQgetlength, "PQgetlength" );
        bindFunc( cast( void** )&PQgetisnull, "PQgetisnull" );
        bindFunc( cast( void** )&PQnparams, "PQnparams" );
        bindFunc( cast( void** )&PQparamtype, "PQparamtype" );
        bindFunc( cast( void** )&PQdescribePrepared, "PQdescribePrepared" );
        bindFunc( cast( void** )&PQdescribePortal, "PQdescribePortal" );
        bindFunc( cast( void** )&PQsendDescribePrepared, "PQsendDescribePrepared" );
        bindFunc( cast( void** )&PQsendDescribePortal, "PQsendDescribePortal" );
        bindFunc( cast( void** )&PQclear, "PQclear" );
        bindFunc( cast( void** )&PQfreemem, "PQfreemem" );
        bindFunc( cast( void** )&PQmakeEmptyPGresult, "PQmakeEmptyPGresult" );
        bindFunc( cast( void** )&PQcopyResult, "PQcopyResult" );
        bindFunc( cast( void** )&PQsetResultAttrs, "PQsetResultAttrs" );
        bindFunc( cast( void** )&PQresultAlloc, "PQresultAlloc" );
        bindFunc( cast( void** )&PQsetvalue, "PQsetvalue" );
        bindFunc( cast( void** )&PQescapeStringConn, "PQescapeStringConn" );
        bindFunc( cast( void** )&PQescapeLiteral, "PQescapeLiteral" );
        bindFunc( cast( void** )&PQescapeIdentifier, "PQescapeIdentifier" );
        bindFunc( cast( void** )&PQescapeByteaConn, "PQescapeByteaConn" );
        bindFunc( cast( void** )&PQunescapeBytea, "PQunescapeBytea" );
        bindFunc( cast( void** )&PQescapeString, "PQescapeString" );
        bindFunc( cast( void** )&PQescapeBytea, "PQescapeBytea" );
        bindFunc( cast( void** )&PQprint, "PQprint" );
        bindFunc( cast( void** )&PQdisplayTuples, "PQdisplayTuples" );
        bindFunc( cast( void** )&PQprintTuples, "PQprintTuples" );
        bindFunc( cast( void** )&lo_open, "lo_open" );
        bindFunc( cast( void** )&lo_close, "lo_close" );
        bindFunc( cast( void** )&lo_read, "lo_read" );
        bindFunc( cast( void** )&lo_write, "lo_write" );
        bindFunc( cast( void** )&lo_lseek, "lo_lseek" );
        bindFunc( cast( void** )&lo_creat, "lo_creat" );
        bindFunc( cast( void** )&lo_create, "lo_create" );
        bindFunc( cast( void** )&lo_tell, "lo_tell" );
        bindFunc( cast( void** )&lo_truncate, "lo_truncate" );
        bindFunc( cast( void** )&lo_unlink, "lo_unlink" );
        bindFunc( cast( void** )&lo_import, "lo_import" );
        bindFunc( cast( void** )&lo_import_with_oid, "lo_import_with_oid" );
        bindFunc( cast( void** )&lo_export, "lo_export" );
        bindFunc( cast( void** )&PQlibVersion, "PQlibVersion" );
        bindFunc( cast( void** )&PQmblen, "PQmblen" );
        bindFunc( cast( void** )&PQdsplen, "PQdsplen" );
        bindFunc( cast( void** )&PQenv2encoding, "PQenv2encoding" );
        bindFunc( cast( void** )&PQencryptPassword, "PQencryptPassword" );
        bindFunc( cast( void** )&pg_char_to_encoding, "pg_char_to_encoding" );
        bindFunc( cast( void** )&pg_encoding_to_char, "pg_encoding_to_char" );
        bindFunc( cast( void** )&pg_valid_server_encoding_id, "pg_valid_server_encoding_id" );
        bindFunc( cast( void** )&PQregisterEventProc, "PQregisterEventProc" );
        bindFunc( cast( void** )&PQsetInstanceData, "PQsetInstanceData" );
        bindFunc( cast( void** )&PQsetSingleRowMode, "PQsetSingleRowMode" );
        bindFunc( cast( void** )&PQconninfo, "PQconninfo" );
        bindFunc( cast( void** )&lo_lseek64, "lo_lseek64" );
        bindFunc( cast( void** )&lo_tell64, "lo_tell64" );
        bindFunc( cast( void** )&lo_truncate64, "lo_truncate64" );
    }
}

__gshared DerelictPQLoader DerelictPQ;

shared static this() {
    DerelictPQ = new DerelictPQLoader();
}
