#include "custom_tcp.h"

kernel_pid_t gnrc_tcp_pid = KERNEL_PID_UNDEF;
static char _stack[TCP_EVENTLOOP_STACK_SIZE + DEBUG_EXTRA_STACKSIZE];

static void *_event_loop(void *args)
{
    msg_t msg, reply, msg_q[GNRC_IPV6_MSG_QUEUE_SIZE];
    gnrc_netreg_entry_t me_reg = GNRC_NETREG_ENTRY_INIT_PID(GNRC_NETREG_DEMUX_CTX_ALL,
                                                            thread_getpid());

    (void)args;
    msg_init_queue(msg_q, GNRC_IPV6_MSG_QUEUE_SIZE);

    /* register interest in all IPv6 packets */
    gnrc_netreg_register(GNRC_NETTYPE_TCP, &me_reg);

    /* preinitialize ACK */
    reply.type = GNRC_NETAPI_MSG_TYPE_ACK;

    /* start event loop */
    while (1)
    {
        DEBUG("custom_tcp: waiting for incoming message.\n");
        msg_receive(&msg);
        add_net_event(NULL);
        switch (msg.type)
        {
        case GNRC_NETAPI_MSG_TYPE_RCV:
            DEBUG("custom_tcp: GNRC_NETAPI_MSG_TYPE_RCV received\n");
            break;

        case GNRC_NETAPI_MSG_TYPE_SND:
            DEBUG("custom_tcp: GNRC_NETAPI_MSG_TYPE_SND received\n");
            break;

        case GNRC_NETAPI_MSG_TYPE_GET:
        case GNRC_NETAPI_MSG_TYPE_SET:
            DEBUG("custom_tcp: reply to unsupported get/set\n");
            reply.content.value = -ENOTSUP;
            msg_reply(&msg, &reply);
            break;
        }
    }
}

kernel_pid_t custom_gnrc_tcp_init(void)
{
    if (gnrc_tcp_pid == KERNEL_PID_UNDEF)
    {
        gnrc_tcp_pid = thread_create(_stack, sizeof(_stack), TCP_EVENTLOOP_PRIO,
                                     THREAD_CREATE_STACKTEST,
                                     _event_loop, NULL, "custom_tcp");
    }
}
