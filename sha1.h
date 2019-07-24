#ifndef SHA1_H
# define SHA1_H

typedef struct  s_sha1
{
    uint32_t    h0;
    uint32_t    h1;
    uint32_t    h2;
    uint32_t    h3;
    uint32_t    h4;
}               t_sha1;

t_sha1    *sha1(void *buf, size_t count);

#endif
