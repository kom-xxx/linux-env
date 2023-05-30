#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <curl/curl.h>
#include <jansson.h>

namespace {
struct RecvData {
	char *data;
	size_t size;
};

const char *commandUrl = "http://10.0.10.128:8080/directcommand";
const char *startPost =
    "{\"method\":\"StartSensorOutput\",\"params\": {\"NetworkID\" : \"999996\"}}";
const char *stopPost = "{\"method\":\"StopSensorOutput\",\"params\": {}}";

size_t
storeData(void *contants, size_t size, size_t nmemb, void *user_data)
{
    size_t real_size = size * nmemb;
    struct RecvData *data = (struct RecvData *)user_data;
    char *data_buf;

    data_buf = malloc(real_size + 1);
    if (!data_buf) {
        fprintf(stderr, "%s: malloc: %s.\n", __func__, strerror(errno));
        return 0;
    }
    memcpy(data_buf, contants, real_size);
    data_buf[real_size] = 0;
    data->data = data_buf;
    data->size = real_size + 1;

    return real_size;
}

int
testResult(char *buf)
{
    int rc = -1;
    json_t *root;
    json_error_t jerr;

    root = json_loads(buf, 0, &jerr);
    if (!root) {
        printf("json_loads: %s.\n", jerr.text);
        return -1;
    }
    json_t *resp = json_object_get(root, "response");
    if (!resp) {
        printf("json_object_get: %s.\n", jerr.text);
        goto error;
    }
    json_t *result = json_object_get(resp, "Result");
    if (!result) {
        printf("json_object_get: %s.\n", jerr.text);
        goto error;
    }

    rc = !!strcmp(json_string_value(result), "Accepted");

error:
    json_decref(root);

    return rc;
}

int
httpXaction(char *url, char *post)
{
    int rc = 0;
    char errbuf[CURL_ERROR_SIZE];
    CURLcode ret;
    CURL *hnd;
    struct curl_slist *slist1;
    struct RecvData data;

    slist1 = NULL;
    slist1 = curl_slist_append(slist1, "Content-Type: application/json");
    slist1 = curl_slist_append(slist1, "Accept: application/json");

    hnd = curl_easy_init();
    curl_easy_setopt(hnd, CURLOPT_BUFFERSIZE, 102400L);
    curl_easy_setopt(hnd, CURLOPT_URL, url);
    curl_easy_setopt(hnd, CURLOPT_POSTFIELDS, post);
    curl_easy_setopt(hnd, CURLOPT_POSTFIELDSIZE_LARGE, (curl_off_t)65);
    curl_easy_setopt(hnd, CURLOPT_HTTPHEADER, slist1);
    curl_easy_setopt(hnd, CURLOPT_USERAGENT, "curl/8.0.1");
    curl_easy_setopt(hnd, CURLOPT_FOLLOWLOCATION, 1L);
    curl_easy_setopt(hnd, CURLOPT_MAXREDIRS, 50L);
    curl_easy_setopt(hnd, CURLOPT_HTTP_VERSION, (long)CURL_HTTP_VERSION_2TLS);
    curl_easy_setopt(hnd, CURLOPT_CUSTOMREQUEST, "POST");
    curl_easy_setopt(hnd, CURLOPT_FTP_SKIP_PASV_IP, 1L);
    curl_easy_setopt(hnd, CURLOPT_TCP_KEEPALIVE, 1L);
    curl_easy_setopt(hnd, CURLOPT_WRITEFUNCTION, storeData);
    curl_easy_setopt(hnd, CURLOPT_WRITEDATA, &data);
    curl_easy_setopt(hnd, CURLOPT_ERRORBUFFER,  &errbuf);

    ret = curl_easy_perform(hnd);
    if (ret) {
        fprintf(stderr, "curl_easy_perform: %s.\n", errbuf);
        rc = -1;
    }

    if (!rc)
        rc = testResult(data.data);

    curl_easy_cleanup(hnd);
    curl_slist_free_all(slist1);

    return rc;
}
}


namespace curl_wrapper {
int
StartSensorOutput(const char *url = commandUrl)
{
	return httpXaction(url, startPost);
}

int
StopSensorOutput(const char *url = commandUrl)
{
	return httpXaction(url, stopPost);
}
}
