package com.zhutao.flutterappfour;

import java.util.List;

/**
 * Created by ad on 2018/3/21.
 */

public class CityBean {

    /**
     * html_attributions : []
     * results : [{"formatted_address":"中国江苏省","geometry":{"location":{"lat":32.060255,"lng":118.796877},"viewport":{"northeast":{"lat":32.3940135,"lng":119.050169},"southwest":{"lat":31.8045247,"lng":118.4253323}}},"icon":"https://maps.gstatic.com/mapfiles/place_api/icons/geocode-71.png","id":"d55f807be6d4ada3ba14bf2f6c452690d81adf76","name":"南京市","photos":[{"height":4898,"html_attributions":["<a href=\"https://maps.google.com/maps/contrib/109909734428832620564/photos\">Aaron Cediel<\/a>"],"photo_reference":"CmRaAAAA8kgb9aJ-RP6T5tFVaxAKO8rdvkgVOTxsmOo8l4vcQ14ExkMqf036FDRnV47FD6bB19h3h13GLGkPSsH3c8cF8EHrV9pKafjW8qILNyi-MUOWx7lMlQLtE0J6zQX_uzjEEhAQEETgtDJohKtmPxy53KgcGhT4f7YrM1w5cPKS8B32ZHroVf-YPA","width":3265}],"place_id":"ChIJg82NZpuMtTURBhvfeQu2-48","reference":"CmRbAAAAkvGObogEo_Cx66_SQdfNPFaajzx9oM13US83P4mWSXpj2FftJMxfUIaWfXaxyuCVgn6hSdeLFU28mUCnpIweXB6LNUPj-wg4TRsmQ6MgEofnxkYrRuM5qSQF9jDU55lREhCYVseuoa6ngll_42DaDVbxGhTVFe3g2Bz9VyR8_jkKRTLp1gu0bQ","types":["locality","political"]}]
     * status : OK
     */

    private String status;
    private List<?> html_attributions;
    private List<ResultsBean> results;

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public List<?> getHtml_attributions() {
        return html_attributions;
    }

    public void setHtml_attributions(List<?> html_attributions) {
        this.html_attributions = html_attributions;
    }

    public List<ResultsBean> getResults() {
        return results;
    }

    public void setResults(List<ResultsBean> results) {
        this.results = results;
    }

    public static class ResultsBean {
        /**
         * formatted_address : 中国江苏省
         * geometry : {"location":{"lat":32.060255,"lng":118.796877},"viewport":{"northeast":{"lat":32.3940135,"lng":119.050169},"southwest":{"lat":31.8045247,"lng":118.4253323}}}
         * icon : https://maps.gstatic.com/mapfiles/place_api/icons/geocode-71.png
         * id : d55f807be6d4ada3ba14bf2f6c452690d81adf76
         * name : 南京市
         * photos : [{"height":4898,"html_attributions":["<a href=\"https://maps.google.com/maps/contrib/109909734428832620564/photos\">Aaron Cediel<\/a>"],"photo_reference":"CmRaAAAA8kgb9aJ-RP6T5tFVaxAKO8rdvkgVOTxsmOo8l4vcQ14ExkMqf036FDRnV47FD6bB19h3h13GLGkPSsH3c8cF8EHrV9pKafjW8qILNyi-MUOWx7lMlQLtE0J6zQX_uzjEEhAQEETgtDJohKtmPxy53KgcGhT4f7YrM1w5cPKS8B32ZHroVf-YPA","width":3265}]
         * place_id : ChIJg82NZpuMtTURBhvfeQu2-48
         * reference : CmRbAAAAkvGObogEo_Cx66_SQdfNPFaajzx9oM13US83P4mWSXpj2FftJMxfUIaWfXaxyuCVgn6hSdeLFU28mUCnpIweXB6LNUPj-wg4TRsmQ6MgEofnxkYrRuM5qSQF9jDU55lREhCYVseuoa6ngll_42DaDVbxGhTVFe3g2Bz9VyR8_jkKRTLp1gu0bQ
         * types : ["locality","political"]
         */

        private String formatted_address;
        private GeometryBean geometry;
        private String icon;
        private String id;
        private String name;
        private String place_id;
        private String reference;
        private List<PhotosBean> photos;
        private List<String> types;

        public String getFormatted_address() {
            return formatted_address;
        }

        public void setFormatted_address(String formatted_address) {
            this.formatted_address = formatted_address;
        }

        public GeometryBean getGeometry() {
            return geometry;
        }

        public void setGeometry(GeometryBean geometry) {
            this.geometry = geometry;
        }

        public String getIcon() {
            return icon;
        }

        public void setIcon(String icon) {
            this.icon = icon;
        }

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getPlace_id() {
            return place_id;
        }

        public void setPlace_id(String place_id) {
            this.place_id = place_id;
        }

        public String getReference() {
            return reference;
        }

        public void setReference(String reference) {
            this.reference = reference;
        }

        public List<PhotosBean> getPhotos() {
            return photos;
        }

        public void setPhotos(List<PhotosBean> photos) {
            this.photos = photos;
        }

        public List<String> getTypes() {
            return types;
        }

        public void setTypes(List<String> types) {
            this.types = types;
        }

        public static class GeometryBean {
            /**
             * location : {"lat":32.060255,"lng":118.796877}
             * viewport : {"northeast":{"lat":32.3940135,"lng":119.050169},"southwest":{"lat":31.8045247,"lng":118.4253323}}
             */

            private LocationBean location;
            private ViewportBean viewport;

            public LocationBean getLocation() {
                return location;
            }

            public void setLocation(LocationBean location) {
                this.location = location;
            }

            public ViewportBean getViewport() {
                return viewport;
            }

            public void setViewport(ViewportBean viewport) {
                this.viewport = viewport;
            }

            public static class LocationBean {
                /**
                 * lat : 32.060255
                 * lng : 118.796877
                 */

                private double lat;
                private double lng;

                public double getLat() {
                    return lat;
                }

                public void setLat(double lat) {
                    this.lat = lat;
                }

                public double getLng() {
                    return lng;
                }

                public void setLng(double lng) {
                    this.lng = lng;
                }
            }

            public static class ViewportBean {
                /**
                 * northeast : {"lat":32.3940135,"lng":119.050169}
                 * southwest : {"lat":31.8045247,"lng":118.4253323}
                 */

                private NortheastBean northeast;
                private SouthwestBean southwest;

                public NortheastBean getNortheast() {
                    return northeast;
                }

                public void setNortheast(NortheastBean northeast) {
                    this.northeast = northeast;
                }

                public SouthwestBean getSouthwest() {
                    return southwest;
                }

                public void setSouthwest(SouthwestBean southwest) {
                    this.southwest = southwest;
                }

                public static class NortheastBean {
                    /**
                     * lat : 32.3940135
                     * lng : 119.050169
                     */

                    private double lat;
                    private double lng;

                    public double getLat() {
                        return lat;
                    }

                    public void setLat(double lat) {
                        this.lat = lat;
                    }

                    public double getLng() {
                        return lng;
                    }

                    public void setLng(double lng) {
                        this.lng = lng;
                    }
                }

                public static class SouthwestBean {
                    /**
                     * lat : 31.8045247
                     * lng : 118.4253323
                     */

                    private double lat;
                    private double lng;

                    public double getLat() {
                        return lat;
                    }

                    public void setLat(double lat) {
                        this.lat = lat;
                    }

                    public double getLng() {
                        return lng;
                    }

                    public void setLng(double lng) {
                        this.lng = lng;
                    }
                }
            }
        }

        public static class PhotosBean {
            /**
             * height : 4898
             * html_attributions : ["<a href=\"https://maps.google.com/maps/contrib/109909734428832620564/photos\">Aaron Cediel<\/a>"]
             * photo_reference : CmRaAAAA8kgb9aJ-RP6T5tFVaxAKO8rdvkgVOTxsmOo8l4vcQ14ExkMqf036FDRnV47FD6bB19h3h13GLGkPSsH3c8cF8EHrV9pKafjW8qILNyi-MUOWx7lMlQLtE0J6zQX_uzjEEhAQEETgtDJohKtmPxy53KgcGhT4f7YrM1w5cPKS8B32ZHroVf-YPA
             * width : 3265
             */

            private int height;
            private String photo_reference;
            private int width;
            private List<String> html_attributions;

            public int getHeight() {
                return height;
            }

            public void setHeight(int height) {
                this.height = height;
            }

            public String getPhoto_reference() {
                return photo_reference;
            }

            public void setPhoto_reference(String photo_reference) {
                this.photo_reference = photo_reference;
            }

            public int getWidth() {
                return width;
            }

            public void setWidth(int width) {
                this.width = width;
            }

            public List<String> getHtml_attributions() {
                return html_attributions;
            }

            public void setHtml_attributions(List<String> html_attributions) {
                this.html_attributions = html_attributions;
            }
        }
    }
}
