#include <iostream>
#include <string.h>
#include <pthread.h>
#include <unistd.h>
#include "ThostFtdcMdApi.h"
//#include <AAextern.h>
#include "MdSpi.h"

extern "C"
{
#include <see_com_common.h>
    double hh[10000] ;
    double ll[10000] ;
    double cc[10000] ;
    double oo[10000] ;
}

int test = 0 ;

/*
*   FUTURE_NUMBER ����ʾ�ж��ٸ��ڻ���
*   pc_futures ��ָ�����飬����  i_rtn = see_futures_init(pc_futures,ca_futures) ;
*   ���г�ʼ����see_futures_init ���../../etc/tbl/see_future_table�ļ����������Щ�ڻ���
*   ������Щ�ڻ���ʼ���� ca_futures��pc_futures��
*/

using namespace std;
/*   globle parameters !!!  */
see_config_t        t_conf ;

char ca_errmsg[256] ;
char ca_jsonfile[] = "../../etc/json/see_brokers.json" ;

CThostFtdcMdApi* pUserApi1;                             // UserApi����

char FRONT_ADDR4[] = "tcp://116.228.246.81:41213";		// ǰ�õ�ַ  �����ڻ�
TThostFtdcBrokerIDType	    BROKER_ID       = "8070";			// ���͹�˾���� �����ڻ�
TThostFtdcInvestorIDType    INVESTOR_ID     = "********";		// Ͷ���ߴ���
TThostFtdcPasswordType      PASSWORD        = "******";		    // �û�����

int     iInstrumentID = 3;									// ���鶩������
int     iRequestID = 1;                                     // ������

cJSON   *json ;
cJSON   *broker ;
cJSON   *ip ;



#define nginx_version      1011006
#define FUTURE_VERSION      "1.11.6"
#define FUTURE_VER          "nginx/" FUTURE_VERSION
#define FUTURE_VER_BUILD    FUTURE_VER "( 1000 )"
#define SEE_LINEFEED             "\x0a"
#define SEE_LINEFEED_SIZE        1


typedef int see_fd_t;
#define see_stderr               STDERR_FILENO
#define see_strlen(s)       strlen((const char *) s)
#define see_inline      inline

static see_inline void see_write_stderr(const char *text);
static see_inline ssize_t see_write_fd(see_fd_t fd, void *buf, size_t n);
static void see_show_version();

int ctpget()
{
    int i_rtn;
    i_rtn = pthread_create(&t_conf.p_dat, NULL, see_pthread_dat, &t_conf);
    if(i_rtn == -1) {
        printf("create thread (save data to database !) failed erron= %d/n", errno);
        return -1;
    }
    //pthread_create(&t_conf.p_bar, NULL, see_pthread_bar, &t_conf);
    //sleep(1) ;


    iInstrumentID = 100;
    pUserApi1 = CThostFtdcMdApi::CreateFtdcMdApi("1.con");          // ����UserApi
    CThostFtdcMdSpi* pUserSpi1 = new CMdSpi();                      // ����UserSpi  ���Դ������


    pUserApi1->RegisterSpi(pUserSpi1);                              // ע���¼���
    pUserApi1->RegisterFront(FRONT_ADDR4);                          // connect

    pUserApi1->Init();
    cout << "after Init() !" << endl;

    //pUserApi1->SubscribeMarketData(pc_futures, iInstrumentID);
    //cout << "  pUserApi1->SubscribeMarketData !!!" << endl ;

    pthread_t pthID = pthread_self();
    cerr << "================main 02 =============================  pthId:" << pthID << endl;

    pUserApi1->Join();
    cout << "after Join() !" << endl;

    pthID = pthread_self();
    cerr << "03 pthId:" << pthID << endl;
    return 0;
}

int
main(int argc,char *argv[])
{

    int pid = 0;
    //see_stt_blocks_init( &t_conf );
    see_show_version();
   

    see_signal_init();                 // ��Ҫ��ϸ����
    signal(SIGHUP, SIG_IGN);
    signal(SIGPIPE, SIG_IGN);
    see_daemon(1,0) ;
    see_config_init(&t_conf);

    if(argc<=1) {
        printf(" ctpget.x will enter into product mode! \n");
        t_conf.c_test = 'p';
    } else {
        if(memcmp(argv[1],"-t",2)==0) {
            printf(" ctpget.x will enter into test mode! \n");
            t_conf.c_test = 't';
        }
        if(memcmp(argv[1],"-p",2)==0) {
            t_conf.c_test = 'p';
        }
    }

    pid = getpid();
    setproctitle_init(argc, argv, environ);
    setproctitle("%s %s", "future:", "master");

    pid = fork();
    switch(pid) {
    case -1:
        return -1;

    case 0:
        pid = getpid();
        setproctitle("%s %s", "future:", "ctpget");
        ctpget() ;
        break;

    default:
        while(1) {
            sleep(100);
        }
        break;
    }

} /* end of main() */




static void
see_show_version()
{
    see_write_stderr(" -- future.x -- version: " FUTURE_VER_BUILD SEE_LINEFEED);

    //if (ngx_show_help) {
    if(1) {
        see_write_stderr(
            "Usage: future.x [-?hvVtTq] [-s signal] [-c filename] "
            "[-p prefix] [-g directives]" SEE_LINEFEED
            SEE_LINEFEED
            "Options:" SEE_LINEFEED
            "  -?,-h         : this help" SEE_LINEFEED
            "  -v            : show version and exit" SEE_LINEFEED
            "  -V            : show version and configure options then exit"
            SEE_LINEFEED
            "  -t            : test configuration and exit" SEE_LINEFEED
            "  -T            : test configuration, dump it and exit"
            SEE_LINEFEED
            "  -q            : suppress non-error messages "
            "during configuration testing" SEE_LINEFEED
            "  -s signal     : send signal to a master process: "
            "stop, quit, reopen, reload" SEE_LINEFEED
            "  -p prefix     : set prefix path (default: NONE)" SEE_LINEFEED
            "  -g directives : set global directives out of configuration "
            "file" SEE_LINEFEED SEE_LINEFEED
        );
    }
}

static see_inline void
see_write_stderr(const char *text)
{
    (void) see_write_fd(see_stderr, (void *)text, see_strlen(text));
}

static see_inline ssize_t
see_write_fd(see_fd_t fd, void *buf, size_t n)
{
    return write(fd, buf, n);
}