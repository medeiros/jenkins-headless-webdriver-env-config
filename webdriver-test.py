"""
Test webdriver (firefox headless) to a given url.
"""

import sys, getopt, codecs

def main():
    myopts, args = getopt.getopt(sys.argv[1:],"u:")
    for param, url in myopts:
        if param == '-u':
            sys.stdout = codecs.getwriter('utf-8')(sys.stdout)

            from selenium import webdriver
            browser=webdriver.Firefox()

            browser.get("http://" + url)

            if browser.page_source:
                print "data found: " + browser.page_source[0:60] + " ..."
            else:
                print "data not found"
        else:
            print ("Usage: %s -u urlToTest" % sys.argv[0])

if __name__ == "__main__":
    main()