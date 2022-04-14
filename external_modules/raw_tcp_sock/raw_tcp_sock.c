#include "raw_tcp_sock.h"

uint8_t tcpbuf[128];

sock_ip_t tcp_sock;
sock_ip_ep_t tcp_local = SOCK_IPV6_EP_ANY;
sock_ip_ep_t tcp_remote;
ssize_t tcp_hdr_size;

void *
raw_tcp_sock_thread(void *args)
{

    if (sock_ip_create(&tcp_sock, &tcp_local, NULL, PROTNUM_TCP, 0) < 0)
    {
        puts("Error creating raw IP tcp_sock");
        return 1;
    }

    while (1)
    {

        sock_ip_ep_t remote = {.family = AF_INET6};
        ssize_t res;

        ipv6_addr_set_all_nodes_multicast((ipv6_addr_t *)&remote.addr.ipv6,
                                          IPV6_ADDR_MCAST_SCP_LINK_LOCAL);

        if ((res = sock_ip_recv(&tcp_sock, tcpbuf, sizeof(tcpbuf), SOCK_NO_TIMEOUT, &tcp_remote)) >= 0)
        {
            DEBUG("\n(RIOT Raw Tcp Socket loop) Received a message\n");
            printf("Size of TCP header = %d\n", res);
            tcp_hdr_size = res;
            add_net_event(NULL);
        }
    }

    return 0;
}

uint16_t get_netif_id(void)
{
    sock_ip_ep_t ep;
    if (sock_ip_get_local(&tcp_sock, &ep) != 0)
        return -1;

    netif_t *netif_p = netif_get_by_id(ep.netif);
    printf("%p\n", netif_p);
    return ep.netif;
}

unsigned int get_ips(void *buf)
{
    // uint16_t netif_id = tcp_sock.local.netif;
    gnrc_netif_t *netif = gnrc_netif_iter(netif);
    printf("Netif id = %d\n", netif->pid);
    ipv6_addr_t ipv6_addrs[CONFIG_GNRC_NETIF_IPV6_ADDRS_NUMOF];
    int res = gnrc_netapi_get(netif->pid, NETOPT_IPV6_ADDR, 0, ipv6_addrs,
                              sizeof(ipv6_addrs));
    memcpy(buf, ipv6_addrs, sizeof(ipv6_addrs));
    // To print the addresses
    for (unsigned i = 0; i < (unsigned)(res / sizeof(ipv6_addr_t)); i++)
    {
        char ipv6_addr[IPV6_ADDR_MAX_STR_LEN];
        ipv6_addr_to_str(ipv6_addr, &ipv6_addrs[i], IPV6_ADDR_MAX_STR_LEN);
        printf("My address is %s\n", ipv6_addr);
    }
    return res / sizeof(ipv6_addr_t);
}

void get_addrs(void *buf)
{
    size_t ipv6_len = sizeof(ipv6_addr_t);
    uint8_t *bufp = (uint8_t *)buf;
    memcpy(bufp, tcp_local.addr.ipv6, ipv6_len);
    bufp += ipv6_len;
    memcpy(bufp, tcp_remote.addr.ipv6, ipv6_len);
    return;
}