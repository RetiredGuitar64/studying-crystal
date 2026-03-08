package main

import (
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

func main() {
	webs := []string{
		"www.baidu.com",
		"www.qq.com",
		"www.taobao.com",
		"www.jd.com",
		"www.tmall.com",
		"www.sina.com.cn",
		"www.sohu.com",
		"www.163.com",
		"www.ifeng.com",
		"www.bilibili.com",
		"www.zhihu.com",
		"www.douban.com",
		"www.weibo.com",
		"www.xiaohongshu.com",
		"www.dianping.com",
		"www.meituan.com",
		"www.alipay.com",
		"www.icbc.com.cn",
		"www.cmbchina.com",
		"www.ctrip.com",
		"www.58.com",
		"www.lagou.com",
		"www.jianshu.com",
		"www.csdn.net",
		"www.cnblogs.com",
		"www.gitee.com",
		"www.oschina.net",
		"www.hupu.com",
		"www.zcool.com.cn",
		"www.4399.com",
		"www.xunlei.com",
		"www.kugou.com",
		"www.qidian.com",
		"www.autohome.com.cn",
		"www.gmw.cn",
		"www.people.com.cn",
		"www.xinhuanet.com",
	}

	ch := make(chan string, len(webs))

	// 一个带超时的 client，避免某些站点一直挂住
	client := &http.Client{Timeout: 10 * time.Second}

	for _, web := range webs {
		go getWeb(client, web, ch)
	}

	var sb strings.Builder
	for i := 0; i < len(webs); i++ {
		sb.WriteString(<-ch)
	}

	fmt.Println(sb.String())
}

func getWeb(client *http.Client, web string, ch chan<- string) {
	url := web
	if !strings.HasPrefix(url, "http://") && !strings.HasPrefix(url, "https://") {
		// 先尝试 https
		url = "https://" + url
	}

	body, err := fetchBody(client, url)
	if err != nil {
		// https 不行再试 http（可选）
		if strings.HasPrefix(url, "https://") {
			body2, err2 := fetchBody(client, "http://"+strings.TrimPrefix(url, "https://"))
			if err2 == nil {
				body = body2
				err = nil
			}
		}
	}

	if err != nil {
		ch <- fmt.Sprintf("[ERROR] %s: %v\n", web, err)
		return
	}

	fmt.Printf("body of %s\n", web)
	ch <- body
}

func fetchBody(client *http.Client, url string) (string, error) {
	resp, err := client.Get(url)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	b, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}
	return string(b), nil
}
